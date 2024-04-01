import Foundation
import Metal

final class RenderPass: GPUPass {
    private struct WaitedFenceIdentifier: Hashable {
        let passId: PassId
        let stage: RenderStage
    }
    
    let id: PassId
    
    let renderTarget: RenderTarget
    
    let name: String?
    
    var asProcessorTaggedPass: ProcessorTaggedPass {
        .gpuPass(self)
    }
    
    var signalledValue: UInt64 {
        if let _signalledValue {
            return _signalledValue
        } else {
            let value = nextSignalValue()
            _signalledValue = value
            return value
        }
    }
    
    private var _signalledValue: UInt64?
    
    private var waitedValue: UInt64?
    
    private var readResources: [Resource: RenderStage] = [:]
    
    private var writtenResources: [Resource: RenderStage] = [:]
        
    private var waitedFences: [WaitedFenceIdentifier: MTLFence] = [:]
    
    private var updatedFences: [RenderStage: MTLFence] = [:]
            
    private let encodeCommands: (inout RenderCommandEncoder) -> Void
    
    private let makeFence: () -> MTLFence
    
    private let nextSignalValue: () -> UInt64
    
    private let sharedEvent: MTLSharedEvent

    init(
        id: PassId,
        renderTarget: RenderTarget,
        sharedEvent: MTLSharedEvent,
        makeFence: @escaping () -> MTLFence,
        nextSignalValue: @escaping () -> UInt64,
        name: String?,
        recordUsage: (borrowing RenderResourceUsageRecorder) -> Void,
        encodeCommands: @escaping (inout RenderCommandEncoder) -> Void
    ) {
        self.id = id
        self.renderTarget = renderTarget
        self.name = name
        self.encodeCommands = encodeCommands
        self.makeFence = makeFence
        self.nextSignalValue = nextSignalValue
        self.sharedEvent = sharedEvent
        
        recordUsage(RenderResourceUsageRecorder(pass: self))
        
        renderTarget.forEachReadAttachmentTexture { texture in
            readResources[.texture(texture)] = .fragment
        }
        
        renderTarget.forEachWrittenAttachmentTexture { texture in
            writtenResources[.texture(texture)] = .fragment
        }
    }
    
    func updatedFence(for resource: Resource) -> MTLFence {
        guard let stage = writtenResources[resource] else {
            preconditionFailure()
        }
        
        return updatedFences[stage, default: makeFence()]
    }
    
    func prepareSyncPoint(for resource: Resource, writtenByPass pass: any Pass) {
        guard let readStage = readResources[resource] else {
            preconditionFailure()
        }
        
        switch pass.asProcessorTaggedPass {
        case .gpuPass(let pass):
            let passId = pass.id
            
            let identifier = WaitedFenceIdentifier(passId: passId, stage: readStage)
            
            if waitedFences[identifier] == nil {
                waitedFences[identifier] = pass.updatedFence(for: resource)
            }
        case .cpuPass(let pass):
            waitedValue = waitedValue.map { previousValue in
                max(previousValue, pass.signalledValue)
            } ?? pass.signalledValue
        }
    }
    
    func allReadResourceSatisfy(_ predicate: (Resource) -> Bool) -> Bool {
        readResources.keys.allSatisfy(predicate)
    }
    
    func forEachReadResource(_ closure: (Resource) -> Void) {
        readResources.keys.forEach(closure)
    }
    
    func forEachWrittenResource(_ closure: (Resource) -> Void) {
        writtenResources.keys.forEach(closure)
    }
    
    func updateResourceUsage() {
        for (_, attachment) in renderTarget.colorAttachments {
            attachment.updateTextureUsage()
        }
        
        if let attachment = renderTarget.depthAttachment {
            attachment.updateTextureUsage()
        }
        
        if let attachment = renderTarget.stencilAttachment {
            attachment.updateTextureUsage()
        }
        
        for (resource, _) in readResources {
            switch resource {
            case .buffer(let buffer):
                fatalError("\(buffer)")
            case .texture(let texture):
                texture.readInShader()
            }
        }
        
        for (resource, _) in writtenResources {
            switch resource {
            case .buffer(let buffer):
                fatalError("\(buffer)")
            case .texture(let texture):
                texture.writeInShader()
            }
        }
    }
    
    func resourceWrite(for resource: Resource) -> ResourceWrite {
        guard let stage = writtenResources[resource] else {
            fatalError("Resource is not written in this pass")
        }
        
        return .renderPass(self, stage: stage)
    }
    
    func readResource(resource: Resource, at stage: RenderStage) {
        if let previousStage = readResources[resource] {
            if stage < previousStage {
               readResources[resource] = stage
            }
        } else {
            readResources[resource] = stage
        }
    }
    
    func writeResource(resource: Resource, at stage: RenderStage) {
        if let previousStage = writtenResources[resource] {
            if stage > previousStage {
                writtenResources[resource] = stage
            }
        } else {
            writtenResources[resource] = stage
        }
    }
    
    func execute(in commandBuffer: MTLCommandBuffer) {
        let renderPassDescriptor = MTLRenderPassDescriptor()
                
        if let attachment = renderTarget.depthAttachment {
            configure(renderPassDescriptor.depthAttachment, with: attachment)
        }
        
        if let attachment = renderTarget.stencilAttachment {
            configure(renderPassDescriptor.stencilAttachment, with: attachment)
        }
        
        for (index, attachment) in renderTarget.colorAttachments {
            configure(renderPassDescriptor.colorAttachments[index], with: attachment)
        }
        
        if let waitedValue {
            commandBuffer.encodeWaitForEvent(sharedEvent, value: waitedValue)
        }
        
        encode(to: commandBuffer, renderPassDescriptor: renderPassDescriptor)
        
        if let _signalledValue {
            commandBuffer.encodeSignalEvent(sharedEvent, value: _signalledValue)
        }
    }
    
    private func encode(to commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor) {
        var encoder = RenderCommandEncoder.to(
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor
        )
        
        for (identifier, fence) in waitedFences {
            encoder.encoder.waitForFence(fence, before: MTLRenderStages(identifier.stage))
        }
        
        for (stage, fence) in updatedFences {
            encoder.encoder.updateFence(fence, after: MTLRenderStages(stage))
        }
        
        encodeCommands(&encoder)
    }
    
    private func configure(_ descriptor: MTLRenderPassStencilAttachmentDescriptor, with attachment: StencilAttachment) {
        descriptor.texture = attachment.texture.mtlTexture
        
        switch attachment.loadAction {
        case .clear(let clearValue):
            descriptor.loadAction = .clear
            descriptor.clearStencil = clearValue.value
        case .load:
            descriptor.loadAction = .load
        case .dontCare:
            descriptor.loadAction = .dontCare
        }
        
        switch attachment.storeAction {
        case .store:
            descriptor.storeAction = .store
        case .dontCare:
            descriptor.storeAction = .dontCare
        }
    }
    
    private func configure(_ descriptor: MTLRenderPassDepthAttachmentDescriptor, with attachment: DepthAttachment) {
        descriptor.texture = attachment.texture.mtlTexture
        
        switch attachment.loadAction {
        case .clear(let clearValue):
            descriptor.loadAction = .clear
            descriptor.clearDepth = clearValue.value
        case .load:
            descriptor.loadAction = .load
        case .dontCare:
            descriptor.loadAction = .dontCare
        }
        
        switch attachment.storeAction {
        case .store:
            descriptor.storeAction = .store
        case .dontCare:
            descriptor.storeAction = .dontCare
        }
    }
    
    private func configure(_ descriptor: MTLRenderPassColorAttachmentDescriptor, with attachment: ColorAttachment) {
        descriptor.texture = attachment.texture.mtlTexture
        
        switch attachment.loadAction {
        case .clear(let clearValue):
            descriptor.loadAction = .clear
            descriptor.clearColor = MTLClearColor(
                red: clearValue.red,
                green: clearValue.green,
                blue: clearValue.blue,
                alpha: clearValue.alpha
            )
        case .load:
            descriptor.loadAction = .load
        case .dontCare:
            descriptor.loadAction = .dontCare
        }
        
        switch attachment.storeAction {
        case .storeAction(let storeAction):
            switch storeAction {
            case .store:
                descriptor.storeAction = .store
            case .dontCare:
                descriptor.storeAction = .dontCare
            }
        case .multisampleResolve(let multisampleResolve):
            fatalError("\(multisampleResolve)")
        }
    }
}

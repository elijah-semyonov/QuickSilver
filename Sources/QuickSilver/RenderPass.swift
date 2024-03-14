import Foundation
import Metal

final class RenderPass: Pass {
    let index: Int
    let renderTarget: RenderTarget
    let name: String?        
    
    private(set) var readResources: [Resource: RenderStage] = [:]
    private(set) var writtenResources: [Resource: RenderStage] = [:]
            
    private let encodeCommands: (inout RenderCommandEncoder) -> Void

    init(
        index: Int,
        renderTarget: RenderTarget,
        name: String?,
        recordUsage: (borrowing RenderResourceUsageRecorder) -> Void,
        encodeCommands: @escaping (inout RenderCommandEncoder) -> Void
    ) {
        self.index = index
        self.renderTarget = renderTarget
        self.name = name
        self.encodeCommands = encodeCommands
        
        recordUsage(RenderResourceUsageRecorder(pass: self))
        
        renderTarget.forEachReadAttachmentTexture { texture in
            readResources[.texture(texture)] = .fragment
        }
        
        renderTarget.forEachWrittenAttachmentTexture { texture in
            writtenResources[.texture(texture)] = .fragment
        }
    }
    
    func iterateResources(ofKind kind: PassResourceKind, stopAfter: (Resource) -> Bool) {
        let keyPath: KeyPath<RenderPass, [Resource: RenderStage]> = switch kind {
        case .read:
            \.readResources
        case .written:
            \.writtenResources
        }
        
        for resource in self[keyPath: keyPath].keys {
            if stopAfter(resource) {
                break
            }
        }
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
    
    func run(using commandBuffer: inout MTLCommandBuffer?, commandQueue: MTLCommandQueue) async {
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
        
        let nonNilCommandBuffer: MTLCommandBuffer
        
        if let commandBuffer {
            nonNilCommandBuffer = commandBuffer
        } else {
            guard let newCommandBuffer = commandQueue.makeCommandBuffer() else {
                fatalError("makeCommandBuffer() returned nil")
            }
            
            commandBuffer = newCommandBuffer
            nonNilCommandBuffer = newCommandBuffer
        }
        
        var encoder = RenderCommandEncoder.to(commandBuffer: nonNilCommandBuffer, renderPassDescriptor: renderPassDescriptor)
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

extension RenderPass: Hashable {
    static func == (lhs: RenderPass, rhs: RenderPass) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

import Foundation
import Metal

final class RenderPass: Pass {
    let id: PassId
    let renderTarget: RenderTarget
    let name: String?        
    
    private(set) var readResources: [Resource: RenderStage] = [:]
    private(set) var writtenResources: [Resource: RenderStage] = [:]
            
    private let encodeCommands: (inout RenderCommandEncoder) -> Void

    init(
        id: PassId,
        renderTarget: RenderTarget,
        name: String?,
        recordUsage: (borrowing RenderResourceUsageRecorder) -> Void,
        encodeCommands: @escaping (inout RenderCommandEncoder) -> Void
    ) {
        self.id = id
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
    
    func execute(in context: PassExecutionContext) async {
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
        
        let commandBuffer = context.commandBuffer(for: self)
        
        var encoder = RenderCommandEncoder.to(
            commandBuffer: commandBuffer,
            renderPassDescriptor: renderPassDescriptor
        )
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

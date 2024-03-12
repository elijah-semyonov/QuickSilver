import Foundation

final class RenderPass: Pass {
    let index: Int
    let renderTarget: RenderTarget
    let name: String?        
    
    private(set) var readResources: [Resource: RenderStage] = [:]
    private(set) var writtenResources: [Resource: RenderStage] = [:]
            
    private let encodeCommands: (borrowing RenderPassCommandEncoder) -> Void

    init(
        index: Int,
        renderTarget: RenderTarget,
        name: String?,
        recordUsage: (borrowing RenderPassResourceUsageRecorder) -> Void,
        encodeCommands: @escaping (borrowing RenderPassCommandEncoder) -> Void
    ) {
        self.index = index
        self.renderTarget = renderTarget
        self.name = name
        self.encodeCommands = encodeCommands
        
        recordUsage(RenderPassResourceUsageRecorder(pass: self))
        
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
}

extension RenderPass: Hashable {
    static func == (lhs: RenderPass, rhs: RenderPass) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

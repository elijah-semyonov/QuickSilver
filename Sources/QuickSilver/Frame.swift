import Foundation
import Metal

public final class Frame {
    private let instance: Instance
    private var passes: [Pass] = []
    private let framesContext: FramesContext
    
    init(instance: Instance, framesContext: FramesContext?) {
        self.instance = instance
                
        self.framesContext = FramesContext(instance: instance)
    }
    
    public func addRenderPass(
        named name: String? = nil,
        renderTarget: RenderTarget,
        recordUsage: (borrowing RenderPassResourceUsageRecorder) -> Void,
        encodeCommands: @escaping (borrowing RenderPassCommandEncoder) -> Void
    ) {
        let pass = RenderPass(
            index: passes.count,
            renderTarget: renderTarget, 
            name: name,
            encodeCommands: encodeCommands
        )
        passes.append(.renderPass(pass))
        
        recordUsage(RenderPassResourceUsageRecorder(pass: pass))
    }
    
    public func addCPUPass(
        named name: String? = nil,
        recordUsage: (borrowing CPUPassResourceUsageRecorder) -> Void,
        invoke: @escaping (CPUPassResources) -> Void
    ) {
        let pass = CPUPass(
            index: passes.count,
            name: name,
            invoke: invoke
        )
        passes.append(.cpuPass(pass))
                
        recordUsage(CPUPassResourceUsageRecorder(pass: pass))
    }
    
    public func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Texture {        
        .texture2D(width: width, height: height, pixelFormat: pixelFormat)
    }
    
    public func makeBuffer() -> Buffer {
        fatalError()
    }
    
    func run() {
        for pass in passes {
            switch pass {
            case .renderPass(let renderPass):
                for (_, attachment) in renderPass.renderTarget.colorAttachments {
                    attachment.updateTextureUsage()
                }
                
                if let attachment = renderPass.renderTarget.depthAttachment {
                    attachment.updateTextureUsage()
                }
                
                if let attachment = renderPass.renderTarget.stencilAttachment {
                    attachment.updateTextureUsage()
                }
                
                for (resource, _) in renderPass.readResources {
                    switch resource {
                    case .buffer(let buffer):
                        fatalError("\(buffer)")
                    case .texture(let texture):
                        texture.readInShader()
                    }
                }
                
                for (resource, _) in renderPass.writtenResources {
                    switch resource {
                    case .buffer(let buffer):
                        fatalError("\(buffer)")
                    case .texture(let texture):
                        texture.writeInShader()
                    }
                }
                
            case .cpuPass(let cpuPass):
                for resource in cpuPass.readResources {
                    switch resource {
                    case .buffer(let buffer):
                        fatalError("\(buffer)")
                    case .texture(let texture):
                        texture.accessByCpu()
                    }
                }
                
                for resource in cpuPass.writtenResources {
                    switch resource {
                    case .buffer(let buffer):
                        fatalError("\(buffer)")
                    case .texture(let texture):
                        texture.accessByCpu()
                    }
                }
            }
        }
        
        var passes = Set(passes)
        var levels: [Set<Pass>] = []
        var resolvedResources: Set<Resource> = []
        
        while true {
            var currentLevel: Set<Pass> = []
            var levelResolvedResources: Set<Resource> = []
                        
            for pass in passes {
                switch pass {
                case .cpuPass(let cpuPass):
                    let resolved = cpuPass.readResources.allSatisfy { resource in
                        resolvedResources.contains(resource)
                    }
                    
                    if resolved {
                        currentLevel.insert(pass)
                        
                        for resource in cpuPass.writtenResources {
                            let (inserted, _) = levelResolvedResources.insert(resource)
                            assert(inserted)
                        }
                    }
                case .renderPass(let renderPass):
                    let resolved = renderPass.readResources.allSatisfy { resource, _ in
                        resolvedResources.contains(resource)
                    }
                    
                    if resolved {
                        currentLevel.insert(pass)
                        
                        renderPass.renderTarget.forEachWrittenAttachmentTexture { texture in
                            let (inserted, _) = levelResolvedResources.insert(.texture(texture))
                            assert(inserted)
                        }
                        
                        for (resource, _) in renderPass.writtenResources {
                            let (inserted, _) = levelResolvedResources.insert(resource)
                            assert(inserted)
                        }
                    }
                }
            }
            
            for resource in levelResolvedResources {
                resolvedResources.insert(resource)
            }
            
            for pass in currentLevel {
                passes.remove(pass)
                currentLevel.insert(pass)
            }
            
            if currentLevel.isEmpty {
                break
            } else {
                levels.append(currentLevel)
            }
        }
        
        precondition(passes.count == 0)
        
        for (index, level) in levels.enumerated() {
            let names = level.map { pass in
                switch pass {
                case .cpuPass(let pass):
                    let name = pass.name.map {
                        "'\($0)'"
                    }
                    
                    return [
                        "CPUPass",
                        name,
                        "#\(pass.index)"
                    ].compactMap { $0 }.joined(separator: " ")
                case .renderPass(let pass):
                    let name = pass.name.map {
                        "'\($0)'"
                    }
                    
                    return [
                        "RenderPass",
                        name,
                        "#\(pass.index)"
                    ].compactMap { $0 }.joined(separator: " ")
                }
            }.joined(separator: ", ")
            
            print(
                """
                Level \(index):
                \(names)
                """
            )
        }
    }
}

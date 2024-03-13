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
        passes.append(
            RenderPass(
                index: passes.count,
                renderTarget: renderTarget,
                name: name,
                recordUsage: recordUsage,
                encodeCommands: encodeCommands
            )
        )
    }
    
    public func addCPUPass(
        named name: String? = nil,
        recordUsage: (borrowing CPUPassResourceUsageRecorder) -> Void,
        invoke: @escaping (CPUPassResources) -> Void
    ) {
        passes.append(
            CPUPass(
                index: passes.count,
                name: name,
                recordUsage: recordUsage,
                invoke: invoke
            )
        )
    }
    
    public func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Texture {        
        .texture2D(width: width, height: height, pixelFormat: pixelFormat)
    }
    
    public func makeBuffer() -> Buffer {
        fatalError()
    }
    
    func execute() async {
        for pass in passes {
            pass.updateResourceUsage()
        }
        
        var passes = Set(passes.map { PassHashableWrapper.wrapping($0) })
        var levels: [Set<PassHashableWrapper>] = []
        var resolvedResources: Set<Resource> = []
        
        while true {
            var currentLevel: Set<PassHashableWrapper> = []
            var levelResolvedResources: Set<Resource> = []
            
            for wrapper in passes {
                let resolved = wrapper.pass.allResourcesSatisfy(kind: .read) { resource in
                    resolvedResources.contains(resource)
                }
                
                if resolved {
                    currentLevel.insert(wrapper)
                    
                    wrapper.pass.forEachResource(ofKind: .written) { resource in
                        levelResolvedResources.insert(resource)
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
        
        debugPrint(levels)
    }
}

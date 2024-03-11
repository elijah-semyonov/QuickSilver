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
        renderTarget: RenderTarget,
        recordUsage: (borrowing RenderPassResourceUsageRecorder) -> Void,
        encodeCommands: @escaping (borrowing RenderPassCommandEncoder) -> Void
    ) {
        let pass = RenderPass(
            index: passes.count,
            renderTarget: renderTarget,
            encodeCommands: encodeCommands
        )
        passes.append(.renderPass(pass))
        
        recordUsage(RenderPassResourceUsageRecorder(pass: pass))
    }
    
    public func addCPUPass(
        recordUsage: (borrowing CPUPassResourceUsageRecorder) -> Void,
        invoke: @escaping (CPUPassResources) -> Void
    ) {
        let pass = CPUPass(
            index: passes.count,
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
                for (resource, stage) in renderPass.readResources {
                    switch resource {
                    case .buffer(let buffer):
                        break
                    case .texture(let texture):
                        //texture
                        break
                    }
                }
                break
            case .cpuPass(let cpuPass):
                break
            }
        }
    }
}

import Foundation
import Metal

public final class Frame {
    private let instance: Instance
    private var passes: [Pass] = []
    private let framesContext: FramesContext
    private var frameResourceUsageTrackers = FrameResourceUsageTrackers()
    
    init(instance: Instance, framesContext: FramesContext?) {
        self.instance = instance
                
        self.framesContext = FramesContext(instance: instance)
    }
    
    public func addRenderPass(
        renderTarget: RenderTarget,
        recordUsage: (inout RenderPassResourceUsageRecorder) -> Void,
        recordCommands: (inout RenderPassCommandRecorder) -> Void
    ) {
        let pass = RenderPass(renderTarget: renderTarget)
        passes.append(.renderPass(pass))
        
//        let usageRecorder = RenderPassResourceUsageRecorder()
//        recordUsage(&pass.usageRecorder)
        recordCommands(&pass.commandRecorder)
    }
    
    public func addCPUPass(
        recordUsage: (inout CPUPassResourceUsageRecorder) -> Void,
        invoke: @escaping (CPUPassResources) -> Void
    ) {
        let pass = CPUPass(invoke: invoke)
        passes.append(.cpuPass(pass))
        
        //let recorder = CPUPassResourceUsageRecorder(pass: pass, trackers: frameResourceUsageTrackers)
    }
    
    public func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Texture {        
        frameResourceUsageTrackers.register(
            TextureUsageTracker(
                width: width,
                height: height,
                depth: 1,
                pixelFormat: pixelFormat
            )
        )
    }
    
    public func makeBuffer() -> Buffer {
        fatalError()
    }
    
    func run() {
    }
}

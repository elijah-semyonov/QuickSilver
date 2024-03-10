import Foundation
import Metal

public final class Frame {
    private let instance: Instance
    private var passes: [Pass] = []
    private let framesContext: FramesContext
    private let allocator: Allocator
    private var frameResourceUsageTrackers = FrameResourceUsageTrackers()
    
    init(instance: Instance, framesContext: FramesContext?) {
        self.instance = instance
        
        let allocator: Allocator
        if let framesContext {
            allocator = framesContext.allocator
        } else {
            allocator = SystemAllocator()
        }
        
        self.allocator = allocator
        self.framesContext = FramesContext(instance: instance, allocator: allocator)
    }
    
    public func addRenderPass(
        renderTarget: RenderTarget,
        recordUsage: (inout RenderPassResourceUsageRecorder) -> Void,
        recordCommands: (inout RenderPassCommandRecorder) -> Void
    ) {
        let pass = RenderPass(renderTarget: renderTarget, allocator: allocator)
        passes.append(.renderPass(pass))
        
        recordUsage(&pass.usageRecorder)
        recordCommands(&pass.commandRecorder)
    }
    
    public func addCPUPass(
        recordUsage: (inout CPUPassResourceUsageRecorder) -> Void,
        invoke: @escaping (CPUPassResources) -> Void
    ) {
        let pass = CPUPass(allocator: allocator, invoke: invoke)
        passes.append(.cpuPass(pass))
        
        recordUsage(&pass.resourceUsageRecorder)
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
        return Buffer()
    }
    
    func run() {
    }
}

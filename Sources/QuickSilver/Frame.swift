import Foundation
import Metal

public final class Frame {
    private let instance: Instance
    private var passes: [Pass] = []
    private let framesContext: FramesContext
    private let allocator: Allocator
    
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
    
    public func addRenderPass(renderTarget: RenderTarget, _ closure: (RenderPass) -> Void) {
        let pass = RenderPass(renderTarget: renderTarget, allocator: allocator)
        passes.append(.renderPass(pass))
                
        closure(pass)
    }
    
    public func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Texture {
        framesContext.makeTexture(width: width, height: height, pixelFormat: pixelFormat)
    }
    
    public func makeBuffer() -> Buffer {
        return Buffer()
    }
    
    func run() {
        
    }
}

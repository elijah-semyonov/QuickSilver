import Foundation
import Metal

public class FramesContext {
    let allocator: Allocator
    
    private let instance: Instance
    private var currentFrameTextures: [TextureUsageData] = []
    
    init(instance: Instance) {
        self.instance = instance
        self.allocator = SystemAllocator()
    }
    
    init(instance: Instance, allocator: Allocator) {
        self.instance = instance
        self.allocator = allocator
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: instance, framesContext: self)
        currentFrameTextures = []
        
        closure(frame)
        
        frame.run()
    }
    
    func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Texture {
        let texture = Texture(index: currentFrameTextures.count)
        
        currentFrameTextures.append(
            TextureUsageData(
                width: width,
                height: height,
                depth: 1,
                pixelFormat: pixelFormat
            )
        )
        
        return texture
    }
}

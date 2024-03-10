import Foundation
import Metal

final class TextureUsageTracker {
    let width: Int
    let height: Int
    let depth: Int
    let pixelFormat: MTLPixelFormat
    let textureType: MTLTextureType
    var usages: [TextureUsageRecord] = []
    var mtlTexture: MTLTexture?
    
    init(width: Int, height: Int, depth: Int, pixelFormat: MTLPixelFormat) {
        self.width = width
        self.height = height
        self.depth = depth
        self.pixelFormat = pixelFormat
        
        textureType = .type2D
    }        
}

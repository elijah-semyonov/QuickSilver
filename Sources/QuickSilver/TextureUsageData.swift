import Foundation
import Metal

final class TextureUsageData {
    let width: Int
    let height: Int
    let depth: Int
    let pixelFormat: MTLPixelFormat
    let textureType: MTLTextureType
    
    init(width: Int, height: Int, depth: Int, pixelFormat: MTLPixelFormat) {
        self.width = width
        self.height = height
        self.depth = depth
        self.pixelFormat = pixelFormat
        
        textureType = .type2D
    }
}

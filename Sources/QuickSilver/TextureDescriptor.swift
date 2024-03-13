import Foundation
import Metal

enum TextureType: Hashable {
    case texture2D(width: Int, height: Int)
}

struct TextureDescriptor: Hashable {
    let type: TextureType
    let pixelFormat: MTLPixelFormat
    var usage: MTLTextureUsage = []
    var storageMode: MTLStorageMode = .memoryless
}

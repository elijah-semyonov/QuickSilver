import Foundation
import Metal

enum TextureType: Hashable {
    case texture2D(width: Int, height: Int)
}

extension MTLResourceUsage: Hashable {
}

extension MTLTextureUsage: Hashable {
}

struct TextureDescriptor: Hashable {
    let type: TextureType
    let pixelFormat: MTLPixelFormat
    var usage: MTLTextureUsage = []
    var storageMode: MTLStorageMode = .memoryless
}

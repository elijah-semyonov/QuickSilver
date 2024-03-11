import Foundation
import Metal

public final class Texture {
    let descriptor = MTLTextureDescriptor()    
    var materialized: MTLTexture?
    
    private init() {
    }
    
    static func texture2D(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Self {
        let texture = Self()
        
        let descriptor = texture.descriptor
        descriptor.width = width
        descriptor.height = height
        descriptor.pixelFormat = pixelFormat
        descriptor.textureType = .type2D
        descriptor.storageMode = .memoryless
        
        return texture
    }
}

extension Texture: Hashable {
    public static func == (lhs: Texture, rhs: Texture) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

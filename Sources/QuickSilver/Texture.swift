import Foundation
import Metal

public final class Texture: Hashable {
    let descriptor = MTLTextureDescriptor()
    var usages: [TextureUsageRecord] = []
    var materialized: MTLTexture?
    
    private init() {
    }
    
    public static func == (lhs: Texture, rhs: Texture) -> Bool {
        lhs === rhs
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
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

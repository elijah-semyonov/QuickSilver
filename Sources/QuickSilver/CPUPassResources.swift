import Foundation
import Metal

public struct CPUPassResources {
    let textures: [Texture: MTLTexture] = [:]
    
    public func withMetalTexture<T>(definedBy texture: Texture, _ closure: (MTLTexture) -> T) -> T {
        guard let mtlTexture = textures[texture] else {
            fatalError("CPUPass used \(texture) without prior declaration")
        }
        
        return closure(mtlTexture)
    }
}

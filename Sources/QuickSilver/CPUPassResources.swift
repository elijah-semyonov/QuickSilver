import Foundation
import Metal

public struct CPUPassResources {
    public func withMetalTexture<T>(definedBy texture: Texture, _ closure: (MTLTexture) -> T) -> T {
        let result = texture.materialized.map(closure)
        
        guard let result else {
            fatalError("CPUPass accessed a texture that wasn't materialized")
        }
        
        return result
    }
}

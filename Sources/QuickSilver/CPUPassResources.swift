import Foundation
import Metal

public struct CPUPassResources {
    public func accessTexture<T>(_ texture: Texture, _ closure: (MTLTexture) -> T) -> T {        
        closure(texture.mtlTexture)
    }
}

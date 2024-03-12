import Foundation
import Metal

public struct Texture: Hashable {
    let impl: TextureImpl
    var mtlTexture: MTLTexture {
        switch impl {
        case .deferred(let deferredTexture):
            guard let mtlTexture = deferredTexture.materialized else {
                fatalError("DeferredTexture is accessed before it is materialized")
            }
            
            return mtlTexture
        }
    }
    
    static func texture2D(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Self {
        let texture = DeferredTexture()
        
        let descriptor = texture.descriptor
        descriptor.width = width
        descriptor.height = height
        descriptor.pixelFormat = pixelFormat
        descriptor.textureType = .type2D
        descriptor.storageMode = .memoryless
        
        return Self(impl: .deferred(texture))
    }
    
    func accessByCpu() {
        ifDeferred { texture in
            let descriptor = texture.descriptor
            
            if descriptor.storageMode != .shared {
                descriptor.storageMode = .shared
            }
        }
    }
    
    func useAsRenderTarget(loadsOrStores: Bool) {
        ifDeferred { texture in
            let descriptor = texture.descriptor
            
            descriptor.usage = .renderTarget
            
            if loadsOrStores && descriptor.storageMode == .memoryless {
                descriptor.storageMode = .private
            }
        }
    }
    
    func readInShader() {
        ifDeferred { texture in
            let descriptor = texture.descriptor
            
            descriptor.usage = .shaderRead
            
            if descriptor.storageMode == .memoryless {
                descriptor.storageMode = .private
            }
        }
    }
    
    func writeInShader() {
        ifDeferred { texture in
            let descriptor = texture.descriptor
            
            descriptor.usage = .shaderWrite
            
            if descriptor.storageMode == .memoryless {
                descriptor.storageMode = .private
            }
        }
    }
    
    private func ifDeferred<T>(_ closure: (DeferredTexture) -> T) -> T? {
        if case .deferred(let deferredTexture) = impl {
            return closure(deferredTexture)
        } else {
            return nil
        }
    }
}

final class DeferredTexture {
    let descriptor = MTLTextureDescriptor()
    var materialized: MTLTexture?
}

extension DeferredTexture: Hashable {
    static func == (lhs: DeferredTexture, rhs: DeferredTexture) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

enum TextureImpl: Hashable {
    case deferred(DeferredTexture)
}

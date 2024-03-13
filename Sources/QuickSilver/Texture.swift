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
        let descriptor = TextureDescriptor(
            type: .texture2D(width: width, height: height),
            pixelFormat: pixelFormat
        )
        
        return Self(impl: .deferred(DeferredTexture(descriptor: descriptor)))
    }
    
    func accessByCpu() {
        ifDeferred { descriptor in
            descriptor.storageMode = .shared
        }
    }
    
    func useAsRenderTarget(loadsOrStores: Bool) {
        ifDeferred { descriptor in
            descriptor.usage.insert(.renderTarget)
            
            if loadsOrStores && descriptor.storageMode == .memoryless {
                descriptor.storageMode = .private
            }
        }
    }
    
    func readInShader() {
        ifDeferred { descriptor in
            descriptor.usage.insert(.shaderRead)
            
            if descriptor.storageMode == .memoryless {
                descriptor.storageMode = .private
            }
        }
    }
    
    func writeInShader() {
        ifDeferred { descriptor in
            descriptor.usage.insert(.shaderWrite)
            
            if descriptor.storageMode == .memoryless {
                descriptor.storageMode = .private
            }
        }
    }
    
    private func ifDeferred<T>(_ closure: (inout TextureDescriptor) -> T) -> T? {
        if case .deferred(let deferredTexture) = impl {
            return closure(&deferredTexture.descriptor)
        } else {
            return nil
        }
    }
}

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
                                
final class DeferredTexture {
    var descriptor: TextureDescriptor
    var materialized: MTLTexture?
    
    init(descriptor: TextureDescriptor) {
        self.descriptor = descriptor
    }
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

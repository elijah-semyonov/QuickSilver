//
//  ResourceRegistry.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import QuartzCore

protocol InferredTexture {
    var texture: Texture { get }
    
    var pixelFormat: PixelFormat { get }
}

class InferredMetalLayerDrawableTexture: InferredTexture {
    let texture: Texture
    let metalLayer: CAMetalLayer
    
    var pixelFormat: PixelFormat {
        switch metalLayer.pixelFormat {
        case .bgra8Unorm_srgb:
            return .bgra8Unorm_srgb
        case .bgra8Unorm:
            return .bgra8Unorm
        default:
            fatalError("Unsupported pixel format")
        }
    }
    
    init(
        texture: Texture,
        metalLayer: CAMetalLayer
    ) {
        self.texture = texture
        self.metalLayer = metalLayer
    }
}

class DeferredTexture: InferredTexture {
    let texture: Texture
    var inferredPixelFormat: PixelFormat?
    var pixelFormat: PixelFormat {
        guard let inferredPixelFormat else {
            fatalError("Couldn't infer pixel format")
        }
        
        return inferredPixelFormat
    }
    
    init(texture: Texture, inferredPixelFormat: PixelFormat?) {
        self.texture = texture
        self.inferredPixelFormat = inferredPixelFormat
    }
}

class ResourceRegistry {
    var nextTextureId: Int = 0
    var textures: [Texture: InferredTexture] = [:]
    
    func deposit(_ metalLayer: CAMetalLayer) -> Texture {
        let texture = nextTexture()
        
        textures[texture] = InferredMetalLayerDrawableTexture(
            texture: texture,
            metalLayer: metalLayer
        )
                
        return texture
    }
    
    func nextTexture() -> Texture {
        defer {
            nextTextureId += 1
        }
        
        return Texture(identifier: nextTextureId)
    }
}

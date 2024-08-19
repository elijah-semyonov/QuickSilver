//
//  ResourceRegistry.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import QuartzCore

class ResourceRegistry {
    var nextTextureId: Int = 0
    var textures: [Texture: InferredTexture] = [:]
    
    func deposit(_ metalLayer: CAMetalLayer) -> Texture {
        let texture = nextTexture()
        
        textures[texture] = MetalDrawableTexture(
            texture: texture,
            metalLayer: metalLayer
        )
                
        return texture
    }
    
    func pixelFormat(of texture: Texture) -> PixelFormat {
        guard let pixelFormat = textures[texture]?.pixelFormat else {
            fatalError("Unknown texture \(texture)")
        }
        
        return pixelFormat
    }
    
    func nextTexture() -> Texture {
        defer {
            nextTextureId += 1
        }
        
        return Texture(identifier: nextTextureId)
    }
}

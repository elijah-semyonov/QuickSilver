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
    
    func pixelFormat(of texture: Texture) -> PixelFormat {
        guard let pixelFormat = textures[texture]?.pixelFormat else {
            fatalError("Unknown texture \(texture)")
        }
        
        return pixelFormat
    }
    
    func deposit<T>(_ inferredTexture: T) -> Texture where T: InferredTexture {
        let texture = nextTexture()
        
        textures[texture] = inferredTexture
        
        return texture
    }
    
    func nextTexture() -> Texture {
        defer {
            nextTextureId += 1
        }
        
        return Texture(identifier: nextTextureId)
    }
}

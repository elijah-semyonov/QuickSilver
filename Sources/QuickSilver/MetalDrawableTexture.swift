//
//  MetalDrawableTexture.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//

import QuartzCore

class MetalDrawableTexture: InferredTexture {
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

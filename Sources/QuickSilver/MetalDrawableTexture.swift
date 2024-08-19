//
//  MetalDrawableTexture.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//

import QuartzCore

class MetalDrawableTexture: InferredTexture {
    let metalLayer: CAMetalLayer
    
    let dataArrangement: TaggedTextureDataArrangement
    
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
        metalLayer: CAMetalLayer
    ) {
        self.metalLayer = metalLayer
        
        self.dataArrangement = .twoDimensional(
            .init(
                width: Int(metalLayer.drawableSize.width),
                height: Int(metalLayer.drawableSize.height),
                count: 1
            )
        )
    }
}

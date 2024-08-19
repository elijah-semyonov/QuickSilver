//
//  DeferredTexture.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//


class DeferredTexture: InferredTexture {
    let texture: Texture
    let pixelFormat: PixelFormat    
    
    init(
        texture: Texture,
        pixelFormat: PixelFormat
    ) {
        self.texture = texture
        self.pixelFormat = pixelFormat
    }
}

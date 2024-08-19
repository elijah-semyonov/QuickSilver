//
//  InferredTexture.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//

protocol InferredTexture {
    var texture: Texture { get }
    
    var pixelFormat: PixelFormat { get }
}

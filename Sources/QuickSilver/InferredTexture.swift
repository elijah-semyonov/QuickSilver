//
//  InferredTexture.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//

protocol InferredTexture {
    var pixelFormat: PixelFormat { get }
    
    var dataArrangement: TaggedTextureDataArrangement { get }
}

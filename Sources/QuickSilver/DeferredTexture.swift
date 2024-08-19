//
//  DeferredTexture.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//

class DeferredTexture: InferredTexture {
    let name: String
    
    let pixelFormat: PixelFormat
    
    let dataArrangement: TaggedTextureDataArrangement
    
    init(
        name: String,
        dataArrangement: TaggedTextureDataArrangement,
        pixelFormat: PixelFormat
    ) {
        self.name = name
        self.dataArrangement = dataArrangement
        self.pixelFormat = pixelFormat
    }
}

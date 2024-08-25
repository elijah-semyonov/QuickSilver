//
//  DeferredTexture.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//

import Foundation

class DeferredTexture: InferredTexture {
    let name: String
    
    let pixelFormat: PixelFormat
    
    let dataArrangement: TaggedTextureDataArrangement
    
    var asTagged: TaggedInferredTexture {
        .deferred(self)
    }
    
    init(
        name: String?,
        dataArrangement: TaggedTextureDataArrangement,
        pixelFormat: PixelFormat
    ) {
        self.name = name  ?? "Deferred texture \(UUID().uuidString)"
        self.dataArrangement = dataArrangement
        self.pixelFormat = pixelFormat
    }
}

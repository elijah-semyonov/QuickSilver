//
//  MetalContext.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import QuartzCore

class MetalContext {
    let backend: MetalBackend
    
    let metalLayer: CAMetalLayer?
    
    init(backend: MetalBackend, metalLayer: CAMetalLayer?) {
        self.backend = backend
        self.metalLayer = metalLayer
    }
    
    func execute(_ draw: (FrameScope) -> Void) {
        let scope = FrameScope(metalLayer: metalLayer)
        
        draw(scope)
    }
}

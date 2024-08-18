//
//  MetalRenderPipeline.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import Metal

class MetalRenderPipelineState {
    let renderPipelineState: MTLRenderPipelineState
    
    init(renderPipelineState: MTLRenderPipelineState) {
        self.renderPipelineState = renderPipelineState
    }
}

//
//  MetalRenderBindingMemorizer.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 25/08/2024.
//

import Metal

class MetalRenderBindingMemorizer {
    struct BufferSlot: Hashable {
        let stage: RenderPassStage
        let index: Int
    }
    
    struct BoundBuffer {
        let buffer: MTLBuffer
        let offset: Int
    }
    
    let encoder: MTLRenderCommandEncoder
    
    var renderPipelineState: MTLRenderPipelineState?
    
    var buffers: [BufferSlot: BoundBuffer] = [:]
    
    init(encoder: MTLRenderCommandEncoder) {
        self.encoder = encoder
    }
    
    func setRenderPipelineState(_ state: MTLRenderPipelineState) {
        if renderPipelineState === state {
            return
        }
        
        renderPipelineState = state
        
        encoder.setRenderPipelineState(state)
    }
    
    func setBuffer(_ buffer: MTLBuffer, bindings: [RenderPassStage: BufferBinding]) {
        for (stage, binding) in bindings {
            let slot = BufferSlot(stage: stage, index: binding.index)
            let newValue = BoundBuffer(buffer: buffer, offset: binding.offset)
            
            if let oldValue = buffers[slot] {
                if newValue.buffer === buffer {
                    if newValue.offset == oldValue.offset {
                        continue
                    } else {
                        switch stage {
                        case .vertex:
                            encoder.setVertexBufferOffset(
                                newValue.offset,
                                index: slot.index
                            )
                        case .fragment:
                            encoder.setFragmentBufferOffset(
                                newValue.offset,
                                index: slot.index
                            )
                        }
                    }
                }
            }
            
            buffers[slot] = newValue
            
            switch stage {
            case .vertex:
                encoder.setVertexBuffer(
                    buffer,
                    offset: newValue.offset,
                    index: slot.index
                )
            case .fragment:
                encoder.setFragmentBuffer(
                    buffer,
                    offset: newValue.offset,
                    index: slot.index
                )
            }
        }
    }
}

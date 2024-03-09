import Foundation
import Metal

public struct RenderPipelineState {
    unowned let wrapped: MTLRenderPipelineState
    
    public static func wrapping(_ state: MTLRenderPipelineState) -> Self {
        return Self(wrapped: state)
    }
}

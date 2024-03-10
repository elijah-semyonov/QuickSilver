import Foundation
import Metal

public struct RenderPipelineState {
    let wrapped: MTLRenderPipelineState
    
    public static func wrapping(_ state: MTLRenderPipelineState) -> Self {
        return Self(wrapped: state)
    }
}

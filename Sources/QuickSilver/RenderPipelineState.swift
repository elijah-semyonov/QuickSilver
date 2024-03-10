import Foundation
import Metal

public struct RenderPipelineState {
    weak var wrapped: MTLRenderPipelineState?
    
    public static func wrapping(_ state: MTLRenderPipelineState) -> Self {
        return Self(wrapped: state)
    }
}

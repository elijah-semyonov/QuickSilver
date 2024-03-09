import Foundation
import Metal

public struct RenderPipelineTarget: Hashable {
    var colorAttachments: [Int: RenderPipelineColorAttachment]
    var depthAttachment: MTLPixelFormat?
    var stencilAttachment: MTLPixelFormat?
}

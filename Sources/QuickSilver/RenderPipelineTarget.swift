import Foundation
import Metal

public struct RenderPipelineTarget: Hashable {
    public let colorAttachments: [Int: RenderPipelineColorAttachment]
    public let depthAttachment: MTLPixelFormat?
    public let stencilAttachment: MTLPixelFormat?
    
    public init(colorAttachments: [Int : RenderPipelineColorAttachment], depthAttachment: MTLPixelFormat? = nil, stencilAttachment: MTLPixelFormat? = nil) {
        self.colorAttachments = colorAttachments
        self.depthAttachment = depthAttachment
        self.stencilAttachment = stencilAttachment
    }
    
    public init(colorAttachments: [RenderPipelineColorAttachment], depthAttachment: MTLPixelFormat? = nil, stencilAttachment: MTLPixelFormat? = nil) {
        self.colorAttachments = Dictionary(uniqueKeysWithValues: colorAttachments.enumerated().map { ($0, $1) })
        self.depthAttachment = depthAttachment
        self.stencilAttachment = stencilAttachment
    }
}

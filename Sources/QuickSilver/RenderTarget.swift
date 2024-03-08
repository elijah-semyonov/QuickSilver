public struct RenderTarget {
    public let colorAttachments: [Int: ColorAttachment]
    public let depthAttachment: DepthAttachment?
    public let stencilAttachment: StencilAttachment?
}

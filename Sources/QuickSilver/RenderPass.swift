public class RenderPass {
    public let colorAttachments: [Int: ColorAttachment]
    public let depthAttachment: DepthAttachment?
    public let stencilAttachment: StencilAttachment?
    
    
    public init(
        colorAttachments: [Int: ColorAttachment],
        depthAttachment: DepthAttachment?,
        stencilAttachment: StencilAttachment?
    ) {
        self.colorAttachments = colorAttachments
        self.depthAttachment = depthAttachment
        self.stencilAttachment = stencilAttachment
    }
}

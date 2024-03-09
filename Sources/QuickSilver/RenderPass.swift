public final class RenderPass: Pass {
    private let renderTarget: RenderTarget
    private var renderCommands: [RenderPassCommand] = []
    private let allocator: Allocator

    init(renderTarget: RenderTarget, allocator: Allocator) {
        self.renderTarget = renderTarget
        self.allocator = allocator
    }
    
    public func setRenderPipelineState(_ state: RenderPipelineState) {
    }
    
    public func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
    }
    
    public func setVertexTexture(_ texture: Texture, index: Int) {
    }
    
    public func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
    }
    
    public func setFragmentTexture(_ texture: Texture, index: Int) {
    }
    
    public func drawPrimitives(type: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int, baseInstance: Int) {
    }
}

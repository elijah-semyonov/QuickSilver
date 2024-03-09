public struct RenderPassCommands: ~Copyable {
    private let renderPass: RenderPass
    
    init(renderPass: RenderPass) {
        self.renderPass = renderPass
    }
    
    func setRenderPipelineState(_ state: RenderPipelineState) {
    }
    
    func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
    }
    
    func setVertexTexture(_ texture: Texture, index: Int) {
    }
    
    func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
    }
    
    func setFragmentTexture(_ texture: Texture, index: Int) {
    }
    
    func drawPrimitives(type: PrimitiveType, vertexStart: Int, vertexCount: Int, instanceCount: Int, baseInstance: Int) {
    }
}

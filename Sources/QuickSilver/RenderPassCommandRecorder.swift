import Foundation

public struct RenderPassCommandRecorder: ~Copyable {
    let allocator: Allocator
    private var list: DeferredComandsList<RenderPassCommand>
    
    init(allocator: Allocator) {
        self.allocator = allocator
        list = DeferredComandsList(allocator: allocator)
    }
    
    public mutating func setRenderPipelineState(_ state: RenderPipelineState) {
        list.append(.setRenderPipelineState(state))
    }
    
    public mutating func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        list.append(RenderPassCommand.setVertexBuffer, SetBufferArgs(buffer: buffer, offset: offset, index: index))
    }
    
    public mutating func setVertexTexture(_ texture: Texture, index: Int) {
        list.append(RenderPassCommand.setVertexTexture, SetTextureArgs(texture: texture, index: index))
    }
    
    public mutating func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        list.append(RenderPassCommand.setFragmentBuffer, SetBufferArgs(buffer: buffer, offset: offset, index: index))
    }
    
    public mutating func setFragmentTexture(_ texture: Texture, index: Int) {
        list.append(RenderPassCommand.setFragmentTexture, SetTextureArgs(texture: texture, index: index))
    }
    
    public mutating func drawPrimitives(type: PrimitiveType = .triangle, vertexStart: Int = 0, vertexCount: Int, instancing: DrawInstancing? = nil) {
        list.append(RenderPassCommand.drawPrimitives, DrawPrimitiveArgs(primitiveType: type, vertexStart: vertexStart, vertexCount: vertexCount, instancing: instancing))
    }
}

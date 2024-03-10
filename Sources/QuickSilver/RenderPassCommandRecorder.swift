import Foundation

public struct RenderPassCommandRecorder: ~Copyable {
    private var commands: [RenderPassCommand] = []
    
    public mutating func setRenderPipelineState(_ state: RenderPipelineState) {
        commands.append(.setRenderPipelineState(state))
    }
    
    public mutating func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        commands.append(.setVertexBuffer(SetBufferArgs(buffer: buffer, offset: offset, index: index)))
    }
    
    public mutating func setVertexTexture(_ texture: Texture, index: Int) {
        commands.append(.setVertexTexture(SetTextureArgs(texture: texture, index: index)))
    }
    
    public mutating func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        commands.append(.setFragmentBuffer(SetBufferArgs(buffer: buffer, offset: offset, index: index)))
    }
    
    public mutating func setFragmentTexture(_ texture: Texture, index: Int) {
        commands.append(.setFragmentTexture(SetTextureArgs(texture: texture, index: index)))
    }
    
    public mutating func drawPrimitives(type: PrimitiveType = .triangle, vertexStart: Int = 0, vertexCount: Int, instancing: DrawInstancing? = nil) {
        commands.append(.drawPrimitives(DrawPrimitiveArgs(primitiveType: type, vertexStart: vertexStart, vertexCount: vertexCount, instancing: instancing)))
    }
}

import Foundation

public struct RenderPassCommandRecorder: ~Copyable {
    let allocator: Allocator
    private var commands: [RenderPassCommand] = []
    
    init(allocator: Allocator) {
        self.allocator = allocator
    }
    
    public mutating func setRenderPipelineState(_ state: RenderPipelineState) {
        append(.setRenderPipelineState(state))
    }
    
    public mutating func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        append(RenderPassCommand.setVertexBuffer, SetBufferArgs(buffer: buffer, offset: offset, index: index))
    }
    
    public mutating func setVertexTexture(_ texture: Texture, index: Int) {
        append(RenderPassCommand.setVertexTexture, SetTextureArgs(texture: texture, index: index))
    }
    
    public mutating func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        append(RenderPassCommand.setFragmentBuffer, SetBufferArgs(buffer: buffer, offset: offset, index: index))
    }
    
    public mutating func setFragmentTexture(_ texture: Texture, index: Int) {
        append(RenderPassCommand.setFragmentTexture, SetTextureArgs(texture: texture, index: index))
    }
    
    public mutating func drawPrimitives(type: PrimitiveType = .triangle, vertexStart: Int = 0, vertexCount: Int, instancing: DrawInstancing? = nil) {
        append(RenderPassCommand.drawPrimitives, DrawPrimitiveArgs(primitiveType: type, vertexStart: vertexStart, vertexCount: vertexCount, instancing: instancing))
    }
    
    mutating func append<Args>(_ makeCommandFromPayload: (UnsafePointer<Args>) -> RenderPassCommand, _ args: Args) {
        let ptr = allocator.store(args)
        let command = makeCommandFromPayload(ptr)
        commands.append(command)
    }
    
    mutating func append(_ command: RenderPassCommand) {
        commands.append(command)
    }
}

import Foundation

public final class RenderPass: Pass {
    private let renderTarget: RenderTarget
    private var renderCommands: [RenderPassCommand] = []
    private let allocator: Allocator

    init(renderTarget: RenderTarget, allocator: Allocator) {
        self.renderTarget = renderTarget
        self.allocator = allocator
    }        
    
    public func setRenderPipelineState(_ state: RenderPipelineState) {
        addCommand(RenderPassCommand.setRenderPipelineState, state)
    }
    
    public func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        addCommand(RenderPassCommand.setVertexBuffer, SetBufferArgs(buffer: buffer, offset: offset, index: index))
    }
    
    public func setVertexTexture(_ texture: Texture, index: Int) {
        addCommand(RenderPassCommand.setVertexTexture, SetTextureArgs(texture: texture, index: index))
    }
    
    public func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        addCommand(RenderPassCommand.setFragmentBuffer, SetBufferArgs(buffer: buffer, offset: offset, index: index))
    }
    
    public func setFragmentTexture(_ texture: Texture, index: Int) {
        addCommand(RenderPassCommand.setFragmentTexture, SetTextureArgs(texture: texture, index: index))
    }
    
    public func drawPrimitives(type: PrimitiveType, vertexStart: Int, vertexCount: Int, instancing: DrawInstancing?) {
        addCommand(RenderPassCommand.drawPrimitives, DrawPrimitiveArgs(primitiveType: type, vertexStart: vertexStart, vertexCount: vertexCount, instancing: instancing))
    }
    
    private func addCommand<Args>(_ makeCommand: (UnsafePointer<Args>) -> RenderPassCommand, _ args: Args) {
        let ptr = allocator.store(args)
        let command = makeCommand(ptr)
        renderCommands.append(command)
    }
}

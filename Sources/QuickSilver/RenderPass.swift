import Foundation

public final class RenderPass {
    private let renderTarget: RenderTarget
    private var commands: [RenderPassCommand] = []        
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
    
    public func drawPrimitives(type: PrimitiveType = .triangle, vertexStart: Int = 0, vertexCount: Int, instancing: DrawInstancing? = nil) {
        addCommand(RenderPassCommand.drawPrimitives, DrawPrimitiveArgs(primitiveType: type, vertexStart: vertexStart, vertexCount: vertexCount, instancing: instancing))
    }
    
    private func addCommand<Args>(_ makeCommand: (UnsafePointer<Args>) -> RenderPassCommand, _ args: Args) {
        let ptr = allocator.store(args)
        let command = makeCommand(ptr)
        commands.append(command)
    }
    
    private func addCommand<Args>(_ makeCommand: (UnsafeMutablePointer<Args>) -> RenderPassCommand, _ args: Args) {
        let ptr = allocator.store(args)
        let command = makeCommand(ptr)
        commands.append(command)
    }
    
    private func freeCommand(_ command: RenderPassCommand) {
        switch command {
        case .setRenderPipelineState(let ptr):
            allocator.wipe(ptr)
        case .drawPrimitives(let ptr):
            allocator.deallocate(ptr)
        case .setVertexBuffer(let ptr):
            allocator.deallocate(ptr)
        case .setVertexTexture(let ptr):
            allocator.deallocate(ptr)
        case .setFragmentBuffer(let ptr):
            allocator.deallocate(ptr)
        case .setFragmentTexture(let ptr):
            allocator.deallocate(ptr)
        }
    }
}

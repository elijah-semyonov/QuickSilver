import Foundation
import Metal

private struct RenderPassResourceBindingSlot: Hashable {
    let stage: RenderStage
    let index: Int
}

private struct RenderPassBufferBinding {
    let buffer: MTLBuffer
    let offset: Int
}

public struct RenderPassCommandEncoder: ~Copyable {
    let encoder: MTLRenderCommandEncoder
    
    private var boundBuffers: [RenderPassResourceBindingSlot: RenderPassBufferBinding] = [:]
    
    public func setRenderPipelineState(_ state: RenderPipelineState) {
        encoder.setRenderPipelineState(state.wrapped)
    }
    
    public func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        setBuffer(buffer, stage: .vertex, offset: offset, index: index)
    }
    
    public func setVertexTexture(_ texture: Texture, index: Int) {
        //commands.append(.setVertexTexture(SetTextureArgs(texture: texture, index: index)))
    }
    
    public func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        //commands.append(.setFragmentBuffer(SetBuffe/*rArgs(buffer: buffer, offset: offset, index: index)))*/
    }
    
    public func setFragmentTexture(_ texture: Texture, index: Int) {
        //commands.append(.setFragmentT/*exture(SetTextureArgs(texture: texture, index: index)))*/
    }
    
    public func drawPrimitives(type: PrimitiveType = .triangle, vertexStart: Int = 0, vertexCount: Int, instancing: DrawInstancing? = nil) {
        //commands.append/*(.drawPrimitives(DrawPrimitiveArgs(primitiveType: type, vertexStart: vertexStart, vertexCount: vertexCount, instancing: instancing)))*/
    }
    
    func setBuffer(_ buffer: Buffer, stage: RenderStage, offset: Int, index: Int) {
        
    }
}


import Foundation

struct SetBufferArgs {
    let buffer: Buffer
    let offset: Int
    let index: Int
}

struct SetTextureArgs {
    let texture: Texture
    let index: Int
}

struct DrawPrimitiveArgs {
    let primitiveType: PrimitiveType
    let vertexStart: Int
    let vertexCount: Int
    let instancing: DrawInstancing?
}

enum RenderCommand {
    case setRenderPipelineState(RenderPipelineState)
    case drawPrimitives(DrawPrimitiveArgs)
    
    case setVertexBuffer(SetBufferArgs)
    case setVertexTexture(SetTextureArgs)
    
    case setFragmentBuffer(SetBufferArgs)
    case setFragmentTexture(SetTextureArgs)         
}

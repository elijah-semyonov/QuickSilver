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

enum RenderPassCommand {
    case setRenderPipelineState(RenderPipelineState)
    case drawPrimitives(UnsafePointer<DrawPrimitiveArgs>)
    
    case setVertexBuffer(UnsafePointer<SetBufferArgs>)
    case setVertexTexture(UnsafePointer<SetTextureArgs>)
    
    case setFragmentBuffer(UnsafePointer<SetBufferArgs>)
    case setFragmentTexture(UnsafePointer<SetTextureArgs>)         
}

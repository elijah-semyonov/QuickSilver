//
//  Commands.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 20/08/2024.
//

struct SetDescribedRenderPipelineStateCommand {
    let descriptor: RenderPipelineDescriptor
}

struct DrawCommand {
    let primitiveType: PrimitiveType
    let vertexStart: Int
    let vertexCount: Int
    let instanceCount: Int
    let baseInstance: Int
    
    init(
        primitiveType: PrimitiveType,
        vertexStart: Int,
        vertexCount: Int,
        instanceCount: Int,
        baseInstance: Int
    ) {
        precondition(vertexCount > 0, "Vertex count must be positive")
        precondition(instanceCount > 0, "Instance count must be positive")        
        precondition((instanceCount == 1 && baseInstance == 0) || instanceCount > 1)
        
        self.primitiveType = primitiveType
        self.vertexStart = vertexStart
        self.vertexCount = vertexCount
        self.instanceCount = instanceCount
        self.baseInstance = baseInstance
    }
}

public struct BufferBinding {
    let index: Int
    let offset: Int
}

struct SetBuffer {
    let buffer: Buffer
}

struct SetRenderBuffer {
    let buffer: Buffer
    let bindings: [RenderPassStage: BufferBinding]
}

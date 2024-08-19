//
//  RenderPassScope.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

public class RenderPassScope {
    enum Command {
        case setDescribedPipelineState(descriptor: RenderPipelineDescriptor)
        case drawTriangles(vertexCount: Int)
    }
    
    let descriptor: RenderPassDescriptor
    var commands: [Command] = []
    
    init(descriptor: RenderPassDescriptor) {
        self.descriptor = descriptor
    }
    
    public func setPipelineState(describedBy descriptor: RenderPipelineDescriptor) {
        commands.append(.setDescribedPipelineState(descriptor: descriptor))
    }
    
    public func drawTriangles(vertexCount: Int) {
        precondition(vertexCount > 0)
        
        commands.append(.drawTriangles(vertexCount: vertexCount))
    }
}

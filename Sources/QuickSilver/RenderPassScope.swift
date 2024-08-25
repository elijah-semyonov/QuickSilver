//
//  RenderPassScope.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

public class RenderPassScope {
    enum Command {
        case setDescribedPipelineState(SetDescribedPipelineStateCommand)
        
        case draw(DrawCommand)
    }
    
    unowned let frameScope: FrameScope
    
    let descriptor: RenderPassDescriptor
    
    var commands: [Command] = []
    
    init(
        frameScope: FrameScope,
        descriptor: RenderPassDescriptor
    ) {
        self.frameScope = frameScope
        self.descriptor = descriptor
    }
    
    public func setState(describedBy pipelineDescriptor: RenderPassPipelineDescriptor) {
        precondition(descriptor.colorAttachments.count == pipelineDescriptor.colorAttachments.count)
        
        let colorAttachmentsRange = 0..<descriptor.colorAttachments.count
        
        commands.append(.setDescribedPipelineState(.init(descriptor: .init(
            vertexName: pipelineDescriptor.vertexName,
            fragmentName: pipelineDescriptor.fragmentName,
            colorAttachments: colorAttachmentsRange.map { index in
                .init(
                    isBlendingEnabled: pipelineDescriptor.colorAttachments[index].isBlendingEnabled,
                    pixelFormat: frameScope.pixelFormat(
                        of: descriptor.colorAttachments[index].texture
                    )
                )
            },
            depthAttachment: descriptor.depthAttachment.map { attachment in
                .init(pixelFormat: frameScope.pixelFormat(of: attachment.texture))
            },
            stencilAttachment: descriptor.stencilAttachment.map { attachment in
                .init(pixelFormat: frameScope.pixelFormat(of: attachment.texture))
            }
        ))))
    }
    
    public func draw(
        primitiveType: PrimitiveType = .triangle,
        vertexStart: Int = 0,
        vertexCount: Int,
        instanceCount: Int = 1,
        baseInstance: Int = 0
    ) {
        precondition(vertexCount > 0)
        
        commands.append(.draw(.init(
            primitiveType: primitiveType,
            vertexStart: vertexStart,
            vertexCount: vertexCount,
            instanceCount: instanceCount,
            baseInstance: baseInstance
        )))
    }
}

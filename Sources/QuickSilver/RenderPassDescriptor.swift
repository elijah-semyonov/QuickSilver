//
//  RenderPassDescriptor.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

public struct RenderPassDescriptor {
    public enum DepthStencilStoreAction {
        case dontCare
        case store
    }
    
    public let colorAttachments: [Int: ColorAttachment]
    public let depthAttachment: DepthAttachment?
    public let stencilAttachment: StencilAttachment?
    
    public init(
        colorAttachments: [Int : ColorAttachment],
        depthAttachment: DepthAttachment?,
        stencilAttachment: StencilAttachment?
    ) {
        self.colorAttachments = colorAttachments
        self.depthAttachment = depthAttachment
        self.stencilAttachment = stencilAttachment
    }
}



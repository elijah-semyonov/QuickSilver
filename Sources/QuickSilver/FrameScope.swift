//
//  FrameScope.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

public protocol FrameScope {
    func renderPass(describedBy: RenderPassDescriptor, _ body: (RenderPassScope) -> Void)
    
    func transientTexture(
        named name: String?,
        pixelFormat: PixelFormat?
    ) -> Texture
}

public protocol PresentableFrameScope: FrameScope {
    var presentableTexture: Texture { get }
}

public extension FrameScope {
    func renderPass(
        colorAttachments: [ColorAttachment],
        depthAttachment: DepthAttachment? = nil,
        stencilAttachment: StencilAttachment? = nil,
        _ body: (RenderPassScope) -> Void
    ) {
        renderPass(describedBy: .init(
            colorAttachments: .init(
                uniqueKeysWithValues: colorAttachments.enumerated().map { $0 }
            ),
            depthAttachment: depthAttachment,
            stencilAttachment: stencilAttachment
        ), body)
    }
    
    func texture() -> Texture {
        transientTexture(named: nil, pixelFormat: nil)
    }
}

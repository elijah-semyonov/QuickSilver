//
//  FrameScope.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

import QuartzCore

public class FrameScope {
    let resourceRegistry: ResourceRegistry
    let actualPresentableTexture: Texture?
    
    init(metalLayer: CAMetalLayer?) {
        let resourceRegistry = ResourceRegistry()
        self.resourceRegistry = resourceRegistry
        
        actualPresentableTexture = metalLayer.map {
            resourceRegistry.deposit($0)
        }
    }
    
    public var presentableTexture: Texture {
        guard let texture = actualPresentableTexture else {
            fatalError("There is no presentable texture associated with this scope")
        }
        
        return texture
    }
    
    public func renderPass(describedBy: RenderPassDescriptor, _ body: (RenderPassScope) -> Void) {
        
    }
    
    public func texture(
        named name: String? = nil,
        pixelFormat: PixelFormat? = nil
    ) -> Texture {
        return Texture(identifier: 0)
    }
    
    public func renderPass(
        colorAttachments: [ColorAttachment],
        depthAttachment: DepthAttachment? = nil,
        stencilAttachment: StencilAttachment? = nil,
        _ body: (RenderPassScope) -> Void
    ) {
        renderPass(describedBy: .init(
            colorAttachments: colorAttachments,
            depthAttachment: depthAttachment,
            stencilAttachment: stencilAttachment
        ), body)
    }
}

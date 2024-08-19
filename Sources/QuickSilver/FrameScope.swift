//
//  FrameScope.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

import QuartzCore

public class FrameScope {
    var nextTextureId: Int = 0
    
    var textures: [Texture: InferredTexture] = [:]
    
    var actualPresentableTexture: Texture?
    
    var passScopes: [RenderPassScope] = []
    
    init(metalLayer: CAMetalLayer?) {
        actualPresentableTexture = metalLayer.map {
            deposit(
                MetalDrawableTexture(metalLayer: $0)
            )
        }
    }
    
    public var presentableTexture: Texture {
        guard let texture = actualPresentableTexture else {
            fatalError("There is no presentable texture associated with this scope")
        }
        
        return texture
    }
    
    public func renderPass(describedBy descriptor: RenderPassDescriptor, _ body: (RenderPassScope) -> Void) {
        let scope = RenderPassScope(descriptor: descriptor)
        
        body(scope)
        
        passScopes.append(scope)
    }
    
    public func texture(
        named name: String? = nil,
        pixelFormat: PixelFormat,
        dataArrangment: TextureDataArrangement1D
    ) -> Texture {
        deposit(
            DeferredTexture(
                name: "Deferred texture \(UUID().uuidString)",
                dataArrangement: .oneDimensional(dataArrangment),
                pixelFormat: pixelFormat
            )
        )
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
    
    func pixelFormat(of texture: Texture) -> PixelFormat {
        guard let pixelFormat = textures[texture]?.pixelFormat else {
            fatalError("Unknown texture \(texture)")
        }
        
        return pixelFormat
    }
    
    func deposit<T>(_ inferredTexture: T) -> Texture where T: InferredTexture {
        let texture = nextTexture()
        
        textures[texture] = inferredTexture
        
        return texture
    }
    
    func nextTexture() -> Texture {
        defer {
            nextTextureId += 1
        }
        
        return Texture(identifier: nextTextureId)
    }
}

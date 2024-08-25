//
//  FrameScope.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

import QuartzCore

public class FrameScope {
    var textureCounter: Int = 0
    
    var bufferCounter: Int = 0
    
    var textures: [Texture: InferredTexture] = [:]
    
    var buffers: [Buffer: InferredBuffer] = [:]
    
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
        let scope = RenderPassScope(frameScope: self, descriptor: descriptor)
        
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
                name: name,
                dataArrangement: .oneDimensional(dataArrangment),
                pixelFormat: pixelFormat
            )
        )
    }
    
    public func buffer<T>(
        named name: String? = nil,
        array: [T]
    ) -> Buffer {
        deposit(
            DeferredInitializedBuffer(
                name: name,
                array: array
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
    
    func deposit<T>(_ inferredBuffer: T) -> Buffer where T: InferredBuffer {
        let buffer = nextBuffer()
        
        buffers[buffer] = inferredBuffer
        
        return buffer
    }
    
    func nextTexture() -> Texture {
        defer {
            textureCounter += 1
        }
        
        return Texture(identifier: textureCounter)
    }
    
    func nextBuffer() -> Buffer {
        defer {
            bufferCounter += 1
        }
        
        return Buffer(identifier: bufferCounter)
    }
}

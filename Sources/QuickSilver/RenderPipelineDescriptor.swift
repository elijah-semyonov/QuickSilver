//
//  RenderPipelineDescriptor.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

public struct RenderPassPipelineColorAttachment: Hashable {
    let isBlendingEnabled: Bool
    
    public init(isBlendingEnabled: Bool) {
        self.isBlendingEnabled = isBlendingEnabled
    }
    
    public static var opaque: Self {
        Self(isBlendingEnabled: false)
    }
    
    public static var transparent: Self {
        Self(isBlendingEnabled: true)
    }
}

public struct RenderPassPipelineDescriptor: Hashable {
    public let vertexName: String
    
    public let fragmentName: String?
    
    public let colorAttachments: [RenderPassPipelineColorAttachment]
    
    public init(
        vertexName: String,
        fragmentName: String?,
        colorAttachments: [RenderPassPipelineColorAttachment]
    ) {
        self.vertexName = vertexName
        self.fragmentName = fragmentName
        self.colorAttachments = colorAttachments
    }
}

public struct RenderPipelineColorAttachment: Hashable {
    public let isBlendingEnabled: Bool
    
    public let pixelFormat: PixelFormat
    
    public init(isBlendingEnabled: Bool, pixelFormat: PixelFormat) {
        self.isBlendingEnabled = isBlendingEnabled
        self.pixelFormat = pixelFormat
    }
}

public struct RenderPipelineDepthAttachment: Hashable {
    public let pixelFormat: PixelFormat
    
    public init(pixelFormat: PixelFormat) {
        self.pixelFormat = pixelFormat
    }
}

public struct RenderPipelineStencilAttachment: Hashable {
    public let pixelFormat: PixelFormat
    
    public init(pixelFormat: PixelFormat) {
        self.pixelFormat = pixelFormat
    }
}

public struct RenderPipelineDescriptor: Hashable {
    public let vertexName: String
    
    public let fragmentName: String?
    
    public let colorAttachments: [RenderPipelineColorAttachment]
    
    public let depthAttachment: RenderPipelineDepthAttachment?
    
    public let stencilAttachment: RenderPipelineStencilAttachment?
    
    public init(
        vertexName: String,
        fragmentName: String?,
        colorAttachments: [RenderPipelineColorAttachment],
        depthAttachment: RenderPipelineDepthAttachment?,
        stencilAttachment: RenderPipelineStencilAttachment?
    ) {
        self.vertexName = vertexName
        self.fragmentName = fragmentName
        self.colorAttachments = colorAttachments
        self.depthAttachment = depthAttachment
        self.stencilAttachment = stencilAttachment
    }
}

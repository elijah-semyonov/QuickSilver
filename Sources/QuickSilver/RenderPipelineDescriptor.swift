//
//  RenderPipelineDescriptor.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

public struct RenderPipelineColorAttachment: Hashable {
    let isOpaque: Bool
    
    public init(isOpaque: Bool) {
        self.isOpaque = isOpaque
    }
}

public struct RenderPipelineDescriptor: Hashable {
    public let vertexName: String
    public let fragmentName: String?
    public let colorAttachments: [Int: RenderPipelineColorAttachment]
    
    public init(vertexName: String, fragmentName: String?, colorAttachments: [Int: RenderPipelineColorAttachment] = [:]) {
        self.vertexName = vertexName
        self.fragmentName = fragmentName
        self.colorAttachments = colorAttachments
    }
}

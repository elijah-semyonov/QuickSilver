//
//  TriangleView.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import SwiftUI
import QuickSilver


class TriangleViewScene {
    let renderPipelineDescriptor = RenderPassPipelineDescriptor(
        vertexName: "vfTriangle",
        fragmentName: "ffTriangle",
        colorAttachments: [
            .opaque
        ]
    )
    
    func draw(in frameScope: FrameScope) {
        frameScope.renderPass(describedBy: .init(
            colorAttachments: [
                .texture(frameScope.presentableTexture, clearedWith: .init(red: 0.05, green: 0.07, blue: 0.1, alpha: 1.0))
            ],
            depthAttachment: nil,
            stencilAttachment: nil
        )) { renderPassScope in
            renderPassScope.setState(describedBy: renderPipelineDescriptor)
            renderPassScope.draw(vertexCount: 3)
        }
    }
}

struct TriangleView: View {
    @State
    var scene: TriangleViewScene = .init()
    
    var body: some View {
        QuickSilverView { scope in
            scene.draw(in: scope)
        }
    }
}

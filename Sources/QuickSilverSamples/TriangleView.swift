//
//  TriangleView.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import SwiftUI
import QuickSilver


class TriangleViewScene {
    let renderPipelineDescriptor = RenderPipelineDescriptor(vertexName: "vfTriangle", fragmentName: "ffTriangle")
    
    func draw(in fScope: FrameScope) {
        fScope.renderPass(describedBy: .init(
            colorAttachments: [
                .texture(fScope.presentableTexture, clearedWith: .init(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0))
            ],
            depthAttachment: nil,
            stencilAttachment: nil
        )) { rpScope in
            rpScope.setPipelineState(describedBy: renderPipelineDescriptor)
            rpScope.drawTriangles(vertexCount: 3)
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

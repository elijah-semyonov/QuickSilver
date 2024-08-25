//
//  TriangleView.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import SwiftUI
import QuickSilver
import Observation

class TriangleViewScene: Observable {
    var colors: [Float] = [
        1, 0, 0,
        0, 1, 0,
        0, 0, 1
    ]
    
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
                .texture(frameScope.presentableTexture, clearedWith: .opaqueBlack)
            ],
            depthAttachment: nil,
            stencilAttachment: nil
        )) { renderPassScope in
            renderPassScope.setState(describedBy: renderPipelineDescriptor)
            renderPassScope.setBuffer(
                frameScope.buffer(
                    named: nil,
                    array: colors
                ),
                bindingIndices: [
                    .vertex: 0
                ]
            )
            renderPassScope.draw(vertexCount: 3)
        }
    }
}

struct TriangleColorComponent: View {
    let name: String
    
    var component: Binding<Float>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(name)
            
            Slider(value: component, in: 0.0...1.0)
        }
    }
    
}

struct TriangleColor: View {
    var red: Binding<Float>
    
    var blue: Binding<Float>
        
    var green: Binding<Float>
    
    var body: some View {
        Section {
            TriangleColorComponent(name: "red", component: red)
            TriangleColorComponent(name: "blue", component: blue)
            TriangleColorComponent(name: "green", component: green)
        }
    }
}

struct TriangleView: View {
    @State
    var scene = TriangleViewScene()
    
    @State
    var useSrgb = false
    
    var pixelFormat: PixelFormat {
        if useSrgb {
            .bgra8Unorm_srgb
        } else {
            .bgra8Unorm
        }
    }
    
    var body: some View {
        HStack(spacing: 0) {
            QuickSilverView(pixelFormat: pixelFormat) { scope in
                scene.draw(in: scope)
            }
            
            List {
                Section {
                    Toggle("Use SRGB render target", isOn: $useSrgb)
                }
                
                ForEach(0..<3) { index in
                    colorView(for: index)
                }
            }.frame(width: 200)
        }
    }
    
    func colorView(for index: Int) -> some View {
        TriangleColor(
            red: $scene.colors[index * 3 + 0],
            blue: $scene.colors[index * 3 + 1],
            green: $scene.colors[index * 3 + 2]
        )
    }
}

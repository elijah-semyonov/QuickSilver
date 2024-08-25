//
//  QuickSilverSamples.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import SwiftUI
import QuickSilver

enum Sample: Hashable {
    case triangle
}

@main
struct QuickSilverSamples: App {
    let samples: [Sample] = [.triangle]
    
    @State
    var selectedSample: Sample?
    
    var body: some Scene {
        WindowGroup {
            HStack(spacing: 0) {
                List(samples, id: \.self, selection: $selectedSample) { sample in
                    switch sample {
                    case .triangle:
                        Text("Triangle")
                    }
                }
                .frame(width: 240)
                
                Group {
                    switch selectedSample {
                    case .triangle:
                        TriangleView()
                    case nil:
                        Text("Select a sample")
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .environment(MetalBackend.initialize(
            libraryBundle: .module
        ))
    }
}

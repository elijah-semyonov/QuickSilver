//
//  QuickSilverSamples.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import SwiftUI
import QuickSilver

@main
struct QuickSilverSamples: App {
    var body: some Scene {
        WindowGroup {
            TriangleView()
        }
        .environment(MetalBackend.initialize(
            libraryBundle: .module
        ))
    }
}

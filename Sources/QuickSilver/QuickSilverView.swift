//
//  QuickSilverView.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 07/08/2024.
//

import SwiftUI

#if os(macOS)
#endif

public struct QuickSilverView: View {
    private let draw: (DrawScope) -> Void
    
    public init(draw: @escaping (DrawScope) -> Void) {
        self.draw = draw
    }
    
    public var body: some View {
        Text("Hello, World!")
    }
}

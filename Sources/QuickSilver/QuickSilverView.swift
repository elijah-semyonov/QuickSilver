//
//  QuickSilverView.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 07/08/2024.
//

import SwiftUI

#if os(macOS)

import AppKit

class QuickSilverNSView: NSView {
    let metalLayer = CAMetalLayer()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        
        wantsLayer = true
        layer = metalLayer
    }
    
    required init?(coder: NSCoder) {
        nil
    }
    
    override func layout() {
        super.layout()
        
        let size = bounds.size
        guard let scale = window?.backingScaleFactor else {
            fatalError("layout() called before attached to window")
        }
        
        let drawableSize = CGSize(width: size.width * scale, height: size.height * scale)
        metalLayer.frame = CGRect(origin: .zero, size: size)
        metalLayer.drawableSize = drawableSize
    }
}

#endif

public struct QuickSilverView: View {
    private let draw: (DrawScope) -> Void
    
    public init(
        pixelFormat: PixelFormat,
        draw: @escaping (DrawScope) -> Void
    ) {
        self.draw = draw
    }
    
    public var body: some View {
        #if os(macOS)
        Text("Not implemented")
        #else
        Text("Not implemented")
        #endif
    }
}

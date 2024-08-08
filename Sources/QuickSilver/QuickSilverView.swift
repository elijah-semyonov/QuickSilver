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
    private let context: MetalContext = .shared
    
    var pixelFormat: PixelFormat {
        didSet {
            updateMetalLayerPixelFormat()
        }
    }
    
    var draw: (DrawScope) -> Void
    
    private var displayLink: CADisplayLink?
    
    private let metalLayer = CAMetalLayer()
    
    init(
        pixelFormat: PixelFormat,
        draw: @escaping (DrawScope) -> Void
    ) {
        self.pixelFormat = pixelFormat
        self.draw = draw
        
        super.init(frame: .zero)
        
        wantsLayer = true
        layer = metalLayer
        
        metalLayer.device = context.device
        metalLayer.allowsNextDrawableTimeout = false
        metalLayer.framebufferOnly = true
        
        updateMetalLayerPixelFormat()
    }
    
    required init?(coder: NSCoder) {
        nil
    }

    
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        
        if let window {
            displayLink?.invalidate()
            let displayLink = displayLink(target: self, selector: #selector(handleDisplayLink))
            displayLink.add(to: .main, forMode: .common)
            self.displayLink = displayLink
        } else {
            displayLink?.invalidate()
            displayLink = nil
        }
    }
    
    override func layout() {
        super.layout()
        
        let size = bounds.size
        guard let scale = window?.backingScaleFactor else {
            fatalError("layout() called before attached to window")
        }
        
        let drawableSize = CGSize(width: size.width * scale, height: size.height * scale)
        metalLayer.frame = .init(origin: .zero, size: size)
        metalLayer.drawableSize = drawableSize
    }
    
    private func updateMetalLayerPixelFormat() {
        metalLayer.pixelFormat = MTLPixelFormat(pixelFormat)
    }
    
    @objc private func handleDisplayLink() {
        guard let displayLink else {
            fatalError()
        }
    }
}

struct QuickSilverNSViewRepresentable: NSViewRepresentable {
    let pixelFormat: PixelFormat
    
    let draw: (DrawScope) -> Void
    
    func makeNSView(context: Context) -> QuickSilverNSView {
        QuickSilverNSView(pixelFormat: pixelFormat, draw: draw)
    }
    
    func updateNSView(_ nsView: QuickSilverNSView, context: Context) {
        nsView.pixelFormat = pixelFormat
        nsView.draw = draw
    }
}

#endif

public struct QuickSilverView: View {
    private let draw: (DrawScope) -> Void
    
    private let pixelFormat: PixelFormat
    
    public init(
        pixelFormat: PixelFormat = .bgra8Unorm_srgb,
        draw: @escaping (DrawScope) -> Void
    ) {
        self.pixelFormat = pixelFormat
        self.draw = draw
    }
    
    public var body: some View {
        #if os(macOS)
        QuickSilverNSViewRepresentable(pixelFormat: pixelFormat, draw: draw)
        #else
        Text("Not implemented")
        #endif
    }
}

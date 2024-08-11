//
//  MetalAdapters.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 11/08/2024.
//

import Metal

extension MTLPixelFormat {
    init(_ value: PixelFormat) {
        switch value {
        case .bgra8Unorm:
            self = .bgra8Unorm
        case .bgra8Unorm_srgb:
            self = .bgra8Unorm_srgb
        }
    }
}

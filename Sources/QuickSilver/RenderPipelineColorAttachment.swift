import Foundation
import Metal

public struct RenderPipelineColorAttachment: Hashable {
    public let pixelFormat: MTLPixelFormat
    public let isBlendingEnabled: Bool
}

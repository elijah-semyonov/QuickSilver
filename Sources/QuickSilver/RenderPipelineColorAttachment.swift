import Foundation
import Metal

public struct RenderPipelineColorAttachment: Hashable {
    public let pixelFormat: MTLPixelFormat
    public let isBlendingEnabled: Bool
    
    public init(pixelFormat: MTLPixelFormat, isBlendingEnabled: Bool) {
        self.pixelFormat = pixelFormat
        self.isBlendingEnabled = isBlendingEnabled
    }
}

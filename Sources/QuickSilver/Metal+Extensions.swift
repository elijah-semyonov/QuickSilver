import Foundation
import Metal

extension MTLResourceUsage: Hashable {
}

extension MTLTextureUsage: Hashable {
}

extension MTLPrimitiveType {
    init(_ type: PrimitiveType) {
        switch type {
        case .triangle:
            self = .triangle
        case .line:
            self = .line
        case .point:
            self = .point
        }
    }
}

extension MTLPixelFormat {
    var bitsPerPixel: Int {
        switch self {
        case .bgra8Unorm, .rgba8Unorm, .bgra8Unorm_srgb, .rgba8Unorm_srgb:
            return 32
        default:
            fatalError("TODO")
        }
    }
    
    var bytesPerPixel: Int {
        bitsPerPixel / 8
    }
}

extension MTLCommandBuffer {
    func commitAndAwaitUntilCompleted() async {
        await withUnsafeContinuation { continuation in
            addCompletedHandler { _ in
                continuation.resume()
            }
            
            commit()
        }
    }
}

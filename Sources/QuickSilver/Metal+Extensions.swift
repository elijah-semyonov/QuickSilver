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

import Foundation
import Metal

public enum PrimitiveType {
    case triangle
    case line
    case point
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

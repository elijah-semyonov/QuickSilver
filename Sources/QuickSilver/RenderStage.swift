import Foundation

public enum RenderStage: UInt8, Comparable, Hashable {
    case vertex = 0
    case fragment = 1
    
    public static func < (lhs: RenderStage, rhs: RenderStage) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}

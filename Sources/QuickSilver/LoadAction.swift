import Foundation

public enum LoadAction<ClearValue> {
    case clear(ClearValue)
    case load
    case dontCare
    
    var isLoadAction: Bool {
        switch self {
        case .load:
            true
        default:
            false
        }
    }
}

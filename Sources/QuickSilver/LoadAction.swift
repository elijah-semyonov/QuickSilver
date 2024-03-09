import Foundation

public enum LoadAction<ClearValue> {
    case clear(ClearValue)
    case load
    case dontCare
}

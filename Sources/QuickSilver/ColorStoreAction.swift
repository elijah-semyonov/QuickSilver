import Foundation

public enum ColorStoreAction {
    case storeAction(StoreAction)
    case multisampleResolve(ColorMultisampleResolve)
    
    public static var store: Self {
        .storeAction(.store)
    }
    
    public static var dontCare: Self {
        .storeAction(.dontCare)
    }
    
    var isStoreAction: Bool {
        switch self {
        case .storeAction(let storeAction):
            switch storeAction {
            case .store:
                true
            default:
                false
            }
        default:
            false
        }
    }
}

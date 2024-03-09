import Foundation

public struct FunctionDescriptor: Hashable {
    public let name: String
    
    public static func named(_ name: String) -> Self {
        return FunctionDescriptor(name: name)
    }
}

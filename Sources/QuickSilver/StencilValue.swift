import Foundation

public struct StencilValue {
    let value: UInt32
    
    public init(value: UInt32) {
        self.value = value
    }
    
    public init() {
        self.value = 0
    }
}

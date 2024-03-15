import Foundation

struct PassId: Hashable {
    let value: Int
    
    init(_ value: Int) {
        self.value = value
    }
}

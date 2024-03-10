import Foundation
import Metal

struct MaterializedBuffer {
    let buffer: MTLBuffer
    let offset: Int
}

public class Buffer: Hashable {
    var materialized: MaterializedBuffer?
    
    public static func == (lhs: Buffer, rhs: Buffer) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

import Metal

struct Fence {
    let wrapped: MTLFence
    
    static func wrapping(_ fence: MTLFence) -> Self {
        return Self(wrapped: fence)
    }
}

extension Fence: Hashable {
    static func == (lhs: Fence, rhs: Fence) -> Bool {
        lhs.wrapped === rhs.wrapped
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(wrapped))
    }
}

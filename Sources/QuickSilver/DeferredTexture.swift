import Foundation
import Metal

final class DeferredTexture {
    var descriptor: TextureDescriptor
    var materialized: MTLTexture?
    
    init(descriptor: TextureDescriptor) {
        self.descriptor = descriptor
    }
}

extension DeferredTexture: Hashable {
    static func == (lhs: DeferredTexture, rhs: DeferredTexture) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

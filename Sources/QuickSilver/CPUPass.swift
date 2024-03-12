import Foundation

final class CPUPass: Pass {
    let index: Int
    let name: String?    
    
    private(set) var readResources: Set<Resource> = []
    private(set) var writtenResources: Set<Resource> = []
    
    private let invoke: (CPUPassResources) -> Void
    
    init(index: Int, name: String?, recordUsage: (borrowing CPUPassResourceUsageRecorder) -> Void, invoke: @escaping (CPUPassResources) -> Void) {
        self.index = index
        self.invoke = invoke
        self.name = name
        
        recordUsage(CPUPassResourceUsageRecorder(pass: self))
    }
    
    func iterateResources(ofKind kind: PassResourceKind, stopAfter: (Resource) -> Bool) {
        let keyPath: KeyPath<CPUPass, Set<Resource>> = switch kind {
        case .read:
            \.readResources
        case .written:
            \.writtenResources
        }
        
        for resource in self[keyPath: keyPath] {
            if stopAfter(resource) {
                break
            }
        }
    }
    
    func updateResourceUsage() {
        for resource in readResources {
            switch resource {
            case .buffer(let buffer):
                fatalError("\(buffer)")
            case .texture(let texture):
                texture.accessByCpu()
            }
        }
        
        for resource in writtenResources {
            switch resource {
            case .buffer(let buffer):
                fatalError("\(buffer)")
            case .texture(let texture):
                texture.accessByCpu()
            }
        }
    }
    
    func readResource(_ resource: Resource) {
        readResources.insert(resource)
    }
    
    func writeResource(_ resource: Resource) {
        writtenResources.insert(resource)
    }
}

extension CPUPass: Hashable {
    public static func == (lhs: CPUPass, rhs: CPUPass) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

import Foundation

enum PassResourceKind {
    case read
    case written
}

protocol Pass where Self: AnyObject {    
    func updateResourceUsage()    
    
    func iterateResources(ofKind kind: PassResourceKind, stopAfter: (Resource) -> Bool)
}

extension Pass {
    func forEachResource(ofKind kind: PassResourceKind, _ closure: (Resource) -> Void) {
        iterateResources(ofKind: kind) { resource in
            closure(resource)
            
            return false
        }
    }
    
    func allResourcesSatisfy(kind: PassResourceKind, _ predicate: (Resource) -> Bool) -> Bool {
        var satisfy = true
        
        iterateResources(ofKind: kind) { resource in
            if predicate(resource) {
                return false
            } else {
                satisfy = false
                return true
            }
        }
        
        return satisfy
    }
}

struct PassHashableWrapper {
    let pass: any Pass
    
    static func wrapping(_ pass: any Pass) -> Self {
        Self(pass: pass)
    }
}

extension PassHashableWrapper: Hashable {
    static func == (lhs: PassHashableWrapper, rhs: PassHashableWrapper) -> Bool {
        lhs.pass === rhs.pass
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(pass))
    }
}

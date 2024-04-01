import Foundation
import Metal

enum PassResourceKind {
    case read
    case written
}

protocol Pass {
    var id: PassId { get }
    
    func updateResourceUsage()
    
    func iterateResources(of kind: PassResourceKind, stopAfter: (Resource) -> Bool)
    
    func execute(in context: PassExecutionContext) async
    
    func resourceWrite(for resource: Resource) -> ResourceWrite
}

extension Pass {
    func forEachResource(ofKind kind: PassResourceKind, _ closure: (Resource) -> Void) {
        iterateResources(of: kind) { resource in
            closure(resource)
            
            return false
        }
    }
    
    func eachResource(of kind: PassResourceKind, satisfies predicate: (Resource) -> Bool) -> Bool {
        var satisfy = true
        
        iterateResources(of: kind) { resource in
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

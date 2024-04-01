import Foundation
import Metal

final class CPUPass: Pass {
    let id: PassId
    let name: String?
    
    var asProcessorTaggedPass: ProcessorTaggedPass {
        .cpuPass(self)
    }
    
    private(set) var readResources: Set<Resource> = []
    private(set) var writtenResources: Set<Resource> = []
    
    private let invoke: (borrowing CPUResources) -> Void
    
    init(id: PassId, name: String?, recordUsage: (borrowing CPUResourceUsageRecorder) -> Void, invoke: @escaping (borrowing CPUResources) -> Void) {
        self.id = id
        self.invoke = invoke
        self.name = name

        
        recordUsage(CPUResourceUsageRecorder(pass: self))
    }
    
    func forEachReadResource(_ closure: (Resource) -> Void) {
        readResources.forEach(closure)
    }
    
    func forEachWrittenResource(_ closure: (Resource) -> Void) {
        writtenResources.forEach(closure)
    }
    
    func allReadResourceSatisfy(_ predicate: (Resource) -> Bool) -> Bool {
        readResources.allSatisfy(predicate)
    }
    
    func prepareSyncPoint(for resource: Resource, writtenByPass pass: any Pass) {
        
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
    
    func resourceWrite(for resource: Resource) -> ResourceWrite {
        guard writtenResources.contains(resource) else {
            fatalError("Resource is not written in this pass")
        }
        
        return .cpuPass(self)
    }
    
    func readResource(_ resource: Resource) {
        readResources.insert(resource)
    }
    
    func writeResource(_ resource: Resource) {
        writtenResources.insert(resource)
    }        
    
    func execute(in context: PassExecutionContext) async {
        await context.awaitBarrier(for: self)
        
        invoke(CPUResources())
    }
}

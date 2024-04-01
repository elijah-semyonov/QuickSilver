import Foundation
import Metal

final class CPUPass: Pass {
    let id: PassId
    
    let name: String?
    
    var asProcessorTaggedPass: ProcessorTaggedPass {
        .cpuPass(self)
    }
    
    var signalledValue: UInt64 {
        if let _signalledValue {
            return _signalledValue
        } else {
            let value = framesContext.nextSignalValue()
            _signalledValue = value
            return value
        }
    }
    
    private var _signalledValue: UInt64?
    
    private var waitedValue: UInt64?
    
    private var readResources: Set<Resource> = []
    
    private var writtenResources: Set<Resource> = []
    
    private let invoke: (borrowing CPUResources) -> Void
    
    private let framesContext: FramesContext
    
    init(
        id: PassId,
        name: String?,
        framesContext: FramesContext,
        recordUsage: (borrowing CPUResourceUsageRecorder) -> Void,
        invoke: @escaping (borrowing CPUResources) -> Void) {
        self.id = id
        self.invoke = invoke
        self.name = name
        self.framesContext = framesContext
        
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
        waitedValue = waitedValue.map { previousValue in
            max(previousValue, pass.signalledValue)
        } ?? pass.signalledValue
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
    
    func execute(in commandBuffer: MTLCommandBuffer) {
        if let waitedValue {
            framesContext.invoke(atSignalValue: waitedValue) { [self] in
                execute()
                
                return _signalledValue
            }
        } else {
            execute()
            
            if let _signalledValue {
                framesContext.updateSignalValue(to: _signalledValue)
            }
        }
    }
    
    private func execute() {
        invoke(CPUResources())
    }
}

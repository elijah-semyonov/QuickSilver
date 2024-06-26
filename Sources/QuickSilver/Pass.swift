import Foundation
import Metal

enum PassResourceAccess {
    case read
    case write
}

enum ProcessorTaggedPass {
    case gpuPass(any GPUPass)
    case cpuPass(CPUPass)
}


protocol Pass {
    var id: PassId { get }
    
    var signalledValue: UInt64 { get }
    
    var asProcessorTaggedPass: ProcessorTaggedPass { get }
    
    func updateResourceUsage()
    
    func execute(in commandBuffer: MTLCommandBuffer)
    
    func resourceWrite(for resource: Resource) -> ResourceWrite
    
    func allReadResourceSatisfy(_ predicate: (Resource) -> Bool) -> Bool
    
    func forEachReadResource(_ closure: (Resource) -> Void)
    
    func forEachWrittenResource(_ closure: (Resource) -> Void)
    
    func prepareSyncPoint(for resource: Resource, writtenByPass pass: Pass)
}

protocol GPUPass: Pass {
    func updatedFence(for resource: Resource) -> MTLFence
}

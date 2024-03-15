import Foundation
import Metal

struct PassExecutionContext {    
    private let passesExecutionCommandBuffers: [PassId: MTLCommandBuffer]
    
    init(passesExecutionCommandBuffers: [PassId : MTLCommandBuffer]) {
        self.passesExecutionCommandBuffers = passesExecutionCommandBuffers
    }
    
    func awaitBarrier(for pass: Pass) async {
        
    }
    
    func commandBuffer(for pass: Pass) -> MTLCommandBuffer {
        guard let commandBuffer = passesExecutionCommandBuffers[pass.id] else {
            fatalError("Pass \(pass.id) doesn't have command buffer to execute on")
        }
        
        return commandBuffer
    }
}

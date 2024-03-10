import Foundation

public class CPUPass {
    var resourceUsageRecorder: CPUPassResourceUsageRecorder
    
    private let allocator: Allocator
    private let invoke: (CPUPassResources) -> Void
    
    init(allocator: Allocator, invoke: @escaping (CPUPassResources) -> Void) {
        self.allocator = allocator
        self.invoke = invoke
        
        resourceUsageRecorder = CPUPassResourceUsageRecorder()
    }
}

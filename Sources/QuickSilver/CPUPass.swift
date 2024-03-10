import Foundation

public class CPUPass {
    private let allocator: Allocator
    private let invoke: (CPUPassResources) -> Void
    
    init(allocator: Allocator, invoke: @escaping (CPUPassResources) -> Void) {
        self.allocator = allocator
        self.invoke = invoke
    }
}

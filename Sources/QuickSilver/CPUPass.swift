import Foundation

public class CPUPass {
    private let invoke: (CPUPassResources) -> Void
    
    init(invoke: @escaping (CPUPassResources) -> Void) {        
        self.invoke = invoke
    }
}

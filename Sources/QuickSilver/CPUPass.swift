import Foundation

public final class CPUPass {
    private let invoke: (CPUPassResources) -> Void
    
    private var readResources: Set<Resource> = []
    private var writtenResources: Set<Resource> = []
    
    init(invoke: @escaping (CPUPassResources) -> Void) {        
        self.invoke = invoke
    }
    
    
}

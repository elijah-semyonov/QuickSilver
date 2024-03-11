import Foundation

final class CPUPass {
    let index: Int
    private(set) var producesSideEffects = false
    
    private let invoke: (CPUPassResources) -> Void
    private var readResources: Set<Resource> = []
    private var writtenResources: Set<Resource> = []
    
    init(index: Int, invoke: @escaping (CPUPassResources) -> Void) { 
        self.index = index
        self.invoke = invoke
    }
    
    func produceSideEffects() {
        producesSideEffects = true
    }
    
    func readResource(_ resource: Resource) {
        readResources.insert(resource)
    }
    
    func writeResource(_ resource: Resource) {
        writtenResources.insert(resource)
    }
}

extension CPUPass: Hashable {
    public static func == (lhs: CPUPass, rhs: CPUPass) -> Bool {
        lhs === rhs
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

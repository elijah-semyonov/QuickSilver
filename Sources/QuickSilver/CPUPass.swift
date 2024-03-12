import Foundation

final class CPUPass {
    let index: Int
    let name: String?
    var dependsOnNothing: Bool {
        readResources.isEmpty
    }
    
    private(set) var readResources: Set<Resource> = []
    private(set) var writtenResources: Set<Resource> = []
    
    private let invoke: (CPUPassResources) -> Void
    
    init(index: Int, name: String?, invoke: @escaping (CPUPassResources) -> Void) { 
        self.index = index
        self.invoke = invoke
        self.name = name
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

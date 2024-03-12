import Foundation

final class RenderPass {
    let index: Int
    let renderTarget: RenderTarget
    let name: String?
    
    var dependsOnNothing: Bool {
        readResources.isEmpty && !renderTarget.hasAnyLoad
    }
    
    private(set) var readResources: [Resource: RenderStage] = [:]
    private(set) var writtenResources: [Resource: RenderStage] = [:]
        
    private let encodeCommands: (borrowing RenderPassCommandEncoder) -> Void

    init(
        index: Int,
        renderTarget: RenderTarget,
        name: String?,
        encodeCommands: @escaping (borrowing RenderPassCommandEncoder) -> Void
    ) {
        self.index = index
        self.renderTarget = renderTarget
        self.name = name
        self.encodeCommands = encodeCommands
    }
    
    func readResource(resource: Resource, at stage: RenderStage) {
        if let previousStage = readResources[resource] {
            if stage < previousStage {
               readResources[resource] = stage
            }
        } else {
            readResources[resource] = stage
        }
    }
    
    func writeResource(resource: Resource, at stage: RenderStage) {
        if let previousStage = writtenResources[resource] {
            if stage > previousStage {
                writtenResources[resource] = stage
            }
        } else {
            writtenResources[resource] = stage
        }
    }
}

extension RenderPass: Hashable {
    static func == (lhs: RenderPass, rhs: RenderPass) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

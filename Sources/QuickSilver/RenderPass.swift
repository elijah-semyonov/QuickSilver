import Foundation

final class RenderPass {
    let index: Int
    let renderTarget: RenderTarget
    private(set) var producesSideEffects = false
    private(set) var readResources: [Resource: RenderStage] = [:]
    private(set) var writtenResources: [Resource: RenderStage] = [:]
        
    private let encodeCommands: (borrowing RenderPassCommandEncoder) -> Void

    init(
        index: Int,
        renderTarget: RenderTarget,
        encodeCommands: @escaping (borrowing RenderPassCommandEncoder) -> Void
    ) {
        self.index = index
        self.renderTarget = renderTarget
        self.encodeCommands = encodeCommands
    }
    
    func produceSideEffects() {
        producesSideEffects = true
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

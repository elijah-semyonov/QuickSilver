import Foundation

final class RenderPass {
    private var readResources: [Resource: RenderStage] = [:]
    private var writtenResources: [Resource: RenderStage] = [:]
    private let renderTarget: RenderTarget
    private let encodeCommands: (borrowing RenderPassCommandEncoder) -> Void

    init(
        renderTarget: RenderTarget,
        encodeCommands: @escaping (borrowing RenderPassCommandEncoder) -> Void
    ) {
        self.renderTarget = renderTarget
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

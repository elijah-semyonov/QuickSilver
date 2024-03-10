import Foundation

final class RenderPass {
    var commandRecorder: RenderPassCommandRecorder
    
    var readResources: [Resource: RenderStage] = [:]
    var writtenResources: [Resource: RenderStage] = [:]
    
    private let renderTarget: RenderTarget

    init(renderTarget: RenderTarget) {
        self.renderTarget = renderTarget
        
        commandRecorder = RenderPassCommandRecorder()
    }
}

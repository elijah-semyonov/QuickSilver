import Foundation

final class RenderPass {
    var commandRecorder: RenderPassCommandRecorder
    
    private let renderTarget: RenderTarget
    private let allocator: Allocator

    init(renderTarget: RenderTarget, allocator: Allocator) {
        self.renderTarget = renderTarget
        self.allocator = allocator
        
        commandRecorder = RenderPassCommandRecorder(allocator: allocator)
    }
}

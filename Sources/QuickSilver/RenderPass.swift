import Foundation

final class RenderPass {
    var usageRecorder: RenderPassResourceUsageRecorder
    var commandRecorder: RenderPassCommandRecorder
    
    private let renderTarget: RenderTarget
    private let allocator: Allocator

    init(renderTarget: RenderTarget, allocator: Allocator) {
        self.renderTarget = renderTarget
        self.allocator = allocator
        
        usageRecorder = RenderPassResourceUsageRecorder()
        commandRecorder = RenderPassCommandRecorder(allocator: allocator)
    }
    
    func inferUsage() {
        
    }
}

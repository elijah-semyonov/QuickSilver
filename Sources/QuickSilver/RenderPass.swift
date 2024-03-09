class RenderPass: Pass {
    private let renderTarget: RenderTarget
    private var renderCommands: [RenderPassCommand] = []
        
    init(renderTarget: RenderTarget) {
        self.renderTarget = renderTarget
    }
}

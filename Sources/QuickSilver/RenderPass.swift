public class RenderPass: Pass {
    let renderTarget: RenderTarget
        
    public init(renderTarget: RenderTarget) {
        self.renderTarget = renderTarget
    }
}

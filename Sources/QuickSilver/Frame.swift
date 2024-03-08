public class Frame {
    private let instance: Instance
    private var passes: [any Pass] = []
    
    init(instance: Instance) {
        self.instance = instance
    }
    
    func end() {
    }
    
    func addRenderPass(renderTarget: RenderTarget, _ closure: (RenderPass) -> Void) {
        let pass = RenderPass(renderTarget: renderTarget)
        passes.append(pass)
        
        closure(pass)    
    }
}

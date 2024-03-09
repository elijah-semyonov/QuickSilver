public class Frame {
    private let instance: Instance
    private var passes: [any Pass] = []
    
    init(instance: Instance) {
        self.instance = instance
    }
    
    public func addRenderPass(renderTarget: RenderTarget, _ closure: (borrowing RenderPassCommands) -> Void) {
        let pass = RenderPass(renderTarget: renderTarget)
        passes.append(pass)
        
        let commands = RenderPassCommands(renderPass: pass)
        closure(commands)
    }
    
    func end() {
    }
}

public class Frame {
    private let instance: Instance
    private var passes: [any Pass] = []
    private let allocator: Allocator
    
    init(instance: Instance, allocator: Allocator) {
        self.instance = instance
        self.allocator = allocator
    }
    
    public func addRenderPass(renderTarget: RenderTarget, _ closure: (RenderPass) -> Void) {
        let pass = RenderPass(renderTarget: renderTarget, allocator: allocator)
        passes.append(pass)
                
        closure(pass)
    }
}

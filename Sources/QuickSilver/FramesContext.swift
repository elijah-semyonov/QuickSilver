import Foundation
import Metal

public class FramesContext {
    let allocator: Allocator
    
    private let instance: Instance
    
    init(instance: Instance) {
        self.instance = instance
        self.allocator = SystemAllocator()
    }
    
    init(instance: Instance, allocator: Allocator) {
        self.instance = instance
        self.allocator = allocator
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: instance, framesContext: self)
        
        closure(frame)
        
        frame.run()
    }
}

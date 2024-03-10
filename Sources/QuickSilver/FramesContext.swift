import Foundation
import Metal

public final class FramesContext {
    private let instance: Instance
    
    init(instance: Instance) {
        self.instance = instance
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: instance, framesContext: self)
        
        closure(frame)
        
        frame.run()
    }
}

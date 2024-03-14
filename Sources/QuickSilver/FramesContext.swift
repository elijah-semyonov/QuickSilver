import Foundation
import Metal

public final class FramesContext {
    private let instance: Instance
    
    init(instance: Instance) {
        self.instance = instance
    }
    
    public func executeFrame(capture: Bool = false, _ closure: (Frame) -> Void) async {
        let frame = Frame(instance: instance, framesContext: self)
        
        closure(frame)
        
        await frame.execute(capture: capture)
    }
}

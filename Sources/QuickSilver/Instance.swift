import Metal

public class Instance {
    let device: MTLDevice
    
    public init(device: MTLDevice) {
        self.device = device
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: self)
        closure(frame)
        frame.end()
    }
}

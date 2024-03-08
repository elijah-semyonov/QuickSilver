import Metal

public class Instance {
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: self)
        closure(frame)
        frame.end()
    }
}

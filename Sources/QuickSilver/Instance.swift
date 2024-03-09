import Metal

public class Instance {
    let device: MTLDevice
    private let allocator = MonotonicAllocator(byteCount: .mebibytes(10))
    
    public init(device: MTLDevice) {
        self.device = device
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: self, allocator: allocator)
        
        closure(frame)
    }
}

import Foundation
import Metal

public class Instance {
    public let device: MTLDevice
    public let library: MTLLibrary
    
    private let allocator = MonotonicAllocator(byteCount: .mebibytes(10))
    private var functions: [Function: MTLFunction] = [:]
    private var renderPipelineStates: [RenderPipelineDescriptor: MTLRenderPipelineState] = [:]
    
    public init(device: MTLDevice) {
        self.device = device
        
        guard let library = device.makeDefaultLibrary() else {
            fatalError("Couldn't create default metal library")
        }
        
        self.library = library
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: self, allocator: allocator)
        
        closure(frame)
    }
    
    public func renderPipelineState(describedBy descriptor: RenderPipelineDescriptor) -> RenderPipelineState {
        fatalError()
    }
}

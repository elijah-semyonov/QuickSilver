import Foundation
import Metal

public class Instance {
    public let device: MTLDevice
    public let library: MTLLibrary
            
    private var functions = Cache<FunctionDescriptor, MTLFunction>()
    private var renderPipelineStates = Cache<RenderPipelineDescriptor, MTLRenderPipelineState>()
    
    public init(device: MTLDevice, library: MTLLibrary) {
        self.device = device        
        self.library = library
    }
    
    public func executeFrame(_ closure: (Frame) -> Void) {
        let frame = Frame(instance: self, framesContext: nil)
        
        closure(frame)
        
        frame.run()
    }
    
    public func renderPipelineState(describedBy descriptor: RenderPipelineDescriptor) async -> RenderPipelineState {
        let state = await renderPipelineStates.get(key: descriptor) { [self] in
            let mtlDescriptor = MTLRenderPipelineDescriptor()
                        
            if let fragmentFunctionDescriptor = descriptor.fragmentFunction {
                async let vertexFunction = function(describedBy: descriptor.vertexFunction)
                async let fragmentFunction = function(describedBy: fragmentFunctionDescriptor)
                
                mtlDescriptor.vertexFunction = await vertexFunction
                mtlDescriptor.fragmentFunction = await fragmentFunction
            } else {
                mtlDescriptor.vertexFunction = await function(describedBy: descriptor.vertexFunction)
            }
            
            descriptor.renderTarget.colorAttachments.forEach { index, attachment in
                configure(mtlDescriptor.colorAttachments[index], using: attachment)
            }
            
            if let pixelFormat = descriptor.renderTarget.depthAttachment {
                mtlDescriptor.depthAttachmentPixelFormat = pixelFormat
            }
            
            if let pixelFormat = descriptor.renderTarget.stencilAttachment {
                mtlDescriptor.stencilAttachmentPixelFormat = pixelFormat
            }
            
            let state: MTLRenderPipelineState
            
            do {
                state = try await device.makeRenderPipelineState(descriptor: mtlDescriptor)
            } catch {
                fatalError("Failed to create render pipeline state using \(descriptor). \(error)")
            }
            
            return state
        }
        
        return .wrapping(state)
    }
    
    func configure(_ mtlDescriptor: MTLRenderPipelineColorAttachmentDescriptor, using descriptor: RenderPipelineColorAttachment) {
        mtlDescriptor.pixelFormat = descriptor.pixelFormat
        mtlDescriptor.isBlendingEnabled = descriptor.isBlendingEnabled
    }
    
    func function(describedBy descriptor: FunctionDescriptor) async -> MTLFunction {
        await functions.get(key: descriptor) { [self] in
            guard let function = library.makeFunction(name: descriptor.name) else {
                fatalError("Couldn't find function named '\(descriptor.name)' in library")
            }
            
            return function
        }
    }
}

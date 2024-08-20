//
//  MetalBackend.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//
import Metal
import QuartzCore

public final class MetalBackend: Observable {
    @MainActor
    static weak var shared: MetalBackend?
    
    let device: MTLDevice
    
    let library: MTLLibrary
    
    let commandQueue: MTLCommandQueue
    
    var renderPipelineCache: [RenderPipelineDescriptor: RenderPipelineState] = [:]
    var mtlRenderPipelineStates: [MTLRenderPipelineState] = []
    
    init(libraryBundle: Bundle?) {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }
        
        let bundle = libraryBundle ?? Bundle.main
        
        let library: MTLLibrary
        do {
            library = try device.makeDefaultLibrary(bundle: bundle)
        } catch {
            fatalError("Failed to create default Metal library. \(error)")
        }
            
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create Metal command queue.")
        }
        
        self.device = device
        self.library = library
        self.commandQueue = commandQueue
    }
    
    func mtlRenderPipelineState(for state: RenderPipelineState) -> MTLRenderPipelineState {
        return mtlRenderPipelineStates[state.identifier]
    }
    
    func mtlRenderPipelineState(for descriptor: RenderPipelineDescriptor) -> MTLRenderPipelineState {
        mtlRenderPipelineState(for: renderPipelineState(for: descriptor))
    }
    
    func renderPipelineState(for descriptor: RenderPipelineDescriptor) -> RenderPipelineState {
        if let state = renderPipelineCache[descriptor] {
            return state
        }
        
        let mtlDescriptor = MTLRenderPipelineDescriptor()
        
        guard let vertexFunction = library.makeFunction(name: descriptor.vertexName) else {
            fatalError("Could not create vertex function.")
        }
        
        let fragmentFunction = descriptor.fragmentName.map {
            guard let function = library.makeFunction(name: $0) else {
                fatalError("Could not create fragment function.")
            }
            
            return function
        }
        
        mtlDescriptor.vertexFunction = vertexFunction
        mtlDescriptor.fragmentFunction = fragmentFunction
        
        descriptor.colorAttachments.enumerated().forEach { index, attachment in
            guard let mtlAttachment = mtlDescriptor.colorAttachments[index] else {
                fatalError()
            }
            
            mtlAttachment.isBlendingEnabled = attachment.isBlendingEnabled
            mtlAttachment.pixelFormat = MTLPixelFormat(attachment.pixelFormat)
        }
        
        if let attachment = descriptor.depthAttachment {
            mtlDescriptor.depthAttachmentPixelFormat = MTLPixelFormat(attachment.pixelFormat)
        }
        
        if let attachment = descriptor.stencilAttachment {
            mtlDescriptor.stencilAttachmentPixelFormat = MTLPixelFormat(attachment.pixelFormat)
        }
        
        let mtlRenderPipelineState: MTLRenderPipelineState
        
        do {
            mtlRenderPipelineState = try device.makeRenderPipelineState(descriptor: mtlDescriptor)
        } catch {
            fatalError("Failed to create Metal render pipeline state. \(error)")
        }
        
        let state = RenderPipelineState(identifier: renderPipelineCache.count)
        
        mtlRenderPipelineStates.append(mtlRenderPipelineState)
        renderPipelineCache[descriptor] = state
        
        return state
    }
    
    @MainActor
    public static func initialize(libraryBundle: Bundle? = nil) -> MetalBackend {
        if let shared {
            return shared
        }
        
        let shared = MetalBackend(libraryBundle: libraryBundle)
        self.shared = shared
        return shared
    }
}

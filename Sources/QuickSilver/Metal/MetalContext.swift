//
//  MetalContext.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 17/08/2024.
//

import QuartzCore
import Metal

class MetalContext {
    let backend: MetalBackend
    
    let metalLayer: CAMetalLayer?
    
    var drawable: CAMetalDrawable?
    
    init(backend: MetalBackend, metalLayer: CAMetalLayer?) {
        self.backend = backend
        self.metalLayer = metalLayer
    }
    
    func execute(_ draw: (FrameScope) -> Void) {
        let frameScope = FrameScope(metalLayer: metalLayer)
        
        draw(frameScope)
        
        guard let commandBuffer = backend.commandQueue.makeCommandBuffer() else {
            fatalError("Failed to create command buffer")
        }
        
        for passScope in frameScope.passScopes {
            let renderPassDescriptor = MTLRenderPassDescriptor()
            
            passScope
                .descriptor
                .colorAttachments
                .enumerated()
                .forEach { index, attachment in
                    guard let configuredAttachment = renderPassDescriptor.colorAttachments[index] else {
                        fatalError("Unexpected nil color attachment at index \(index)")
                    }
                    
                    configuredAttachment.texture = materialize(frameScope: frameScope, texture: attachment.texture)
                    switch attachment.loadAction {
                    case .load:
                        configuredAttachment.loadAction = .load
                    case .clear(let clearColor):
                        configuredAttachment.loadAction = .clear
                        configuredAttachment.clearColor = MTLClearColor(red: clearColor.red, green: clearColor.green, blue: clearColor.blue, alpha: clearColor.alpha)
                    case .none:
                        configuredAttachment.loadAction = .dontCare
                    }
                    
                    configuredAttachment.storeAction = .store
                }
            
            passScope
                .descriptor
                .depthAttachment
                .map { attachment in
                    guard let configuredAttachment = renderPassDescriptor.depthAttachment else {
                        fatalError("Unexpected nil depth attachment")
                    }
                    
                    configuredAttachment.texture = materialize(frameScope: frameScope, texture: attachment.texture)
                    switch attachment.loadAction {
                    case .load:
                        configuredAttachment.loadAction = .load
                    case .clear(let clearDepth):
                        configuredAttachment.loadAction = .clear
                        configuredAttachment.clearDepth = clearDepth.value
                    case .none:
                        configuredAttachment.loadAction = .dontCare
                    }
                }
            
            passScope
                .descriptor
                .stencilAttachment
                .map { attachment in
                    guard let configuredAttachment = renderPassDescriptor.stencilAttachment else {
                        fatalError("Unexpected nil depth attachment")
                    }
                    
                    configuredAttachment.texture = materialize(frameScope: frameScope, texture: attachment.texture)
                    switch attachment.loadAction {
                    case .load:
                        configuredAttachment.loadAction = .load
                    case .clear(let clearStencil):
                        configuredAttachment.loadAction = .clear
                        configuredAttachment.clearStencil = clearStencil.value
                    case .none:
                        configuredAttachment.loadAction = .dontCare
                    }
                }
            
            guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
                fatalError("Failed to create render command encoder")
            }
            
            let memorizer = MetalRenderBindingMemorizer(encoder: encoder)
            
            for command in passScope.commands {
                switch command {
                case .setBuffer(let command):
                    let (mtlBuffer, offset) = materialize(
                        frameScope: frameScope,
                        buffer: command.buffer
                    )
                    
                    memorizer.setBuffer(
                        mtlBuffer,
                        bindings: command.bindings.mapValues { binding in
                            .init(
                                index: binding.index,
                                offset: binding.offset + offset
                            )
                        }
                    )
                    
                case .setDescribedPipelineState(let command):
                    let state = backend.mtlRenderPipelineState(for: command.descriptor)
                    encoder.setRenderPipelineState(state)                
                case .draw(let command):
                    let primitiveType = MTLPrimitiveType(command.primitiveType)
                    
                    if command.instanceCount > 1 {
                        if command.baseInstance != 0 {
                            encoder.drawPrimitives(
                                type: primitiveType,
                                vertexStart: command.vertexStart,
                                vertexCount: command.vertexCount,
                                instanceCount: command.instanceCount,
                                baseInstance: command.baseInstance
                            )
                        } else {
                            encoder.drawPrimitives(
                                type: primitiveType,
                                vertexStart: command.vertexStart,
                                vertexCount: command.vertexCount,
                                instanceCount: command.instanceCount                                
                            )
                        }
                    } else {
                        encoder.drawPrimitives(
                            type: primitiveType,
                            vertexStart: command.vertexStart,
                            vertexCount: command.vertexCount
                        )
                    }
                }
            }
            
            encoder.endEncoding()
        }
        
        if let drawable {
            commandBuffer.present(drawable)
        }
        
        commandBuffer.commit()
    }
    
    func materialize(frameScope: FrameScope, buffer: Buffer) -> (MTLBuffer, offset: Int) {
        guard let inferredBuffer = frameScope.buffers[buffer] else {
            fatalError("Unknown buffer \(buffer)")
        }
        
        switch inferredBuffer.asTagged {
        case .deferredInitialized(let buffer):
            let mtlBuffer = buffer.source.withUnsafeRawBufferPointer { bufferPtr in
                guard let bytes = bufferPtr.baseAddress else { return nil as MTLBuffer? }
                
                return backend.device.makeBuffer(bytes: bytes, length: bufferPtr.count, options: [])
            }
            
            guard let mtlBuffer else {
                fatalError("Couldn't materialize buffer \(buffer)")
            }
            
            return (mtlBuffer, 0)
        }
    }
    
    func materialize(frameScope: FrameScope, texture: Texture) -> MTLTexture {
        guard let inferredTexture = frameScope.textures[texture] else {
            fatalError("Unknown texture \(texture)")
        }
        
        switch inferredTexture.asTagged {
        case .deferred(let texture):
            fatalError()
        case .metalDrawable(let texture):
            guard let drawable = texture.metalLayer.nextDrawable() else {
                fatalError("CAMetalLayer.nextDrawable() time-out is not supported")
            }
            
            self.drawable = drawable
            let texture = drawable.texture
            
            return texture
        }
    }
}

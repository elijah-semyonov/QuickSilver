import Foundation
import Metal

private struct RenderPassResourceBindingSlot: Hashable {
    let stage: RenderStage
    let index: Int
}

private struct RenderPassBufferBindingValue {
    let buffer: MTLBuffer
    let offset: Int
}

public struct RenderCommandEncoder: ~Copyable {
    let encoder: MTLRenderCommandEncoder
    
    private var boundBuffers: [RenderPassResourceBindingSlot: RenderPassBufferBindingValue] = [:]
    private var boundTextures: [RenderPassResourceBindingSlot: Texture] = [:]
    
    deinit {
        encoder.endEncoding()
    }
    
public func setRenderPipelineState(_ state: RenderPipelineState) {
        encoder.setRenderPipelineState(state.wrapped)
    }
    
    public func drawPrimitives(type: PrimitiveType = .triangle, vertexStart: Int = 0, vertexCount: Int, instancing: DrawInstancing? = nil) {
        let type = MTLPrimitiveType(type)
        
        if let instancing {
            if let base = instancing.base {
                encoder.drawPrimitives(type: type, vertexStart: vertexStart, vertexCount: vertexCount, instanceCount: instancing.count, baseInstance: base)
            } else {
                encoder.drawPrimitives(type: type, vertexStart: vertexStart, vertexCount: vertexCount, instanceCount: instancing.count)
            }
        } else {
            encoder.drawPrimitives(type: type, vertexStart: vertexStart, vertexCount: vertexCount)
        }
    }
    
    public mutating func setVertexBytes<T>(_ value: T, index: Int) {
        withUnsafePointer(to: value) { ptr in
            boundBuffers[RenderPassResourceBindingSlot(stage: .vertex, index: index)] = nil
            encoder.setVertexBytes(ptr, length: MemoryLayout<T>.size, index: index)
        }        
    }
    
    public mutating func setFragmentBytes<T>(_ value: T, index: Int) {
        withUnsafePointer(to: value) { ptr in
            boundBuffers[RenderPassResourceBindingSlot(stage: .fragment, index: index)] = nil
            encoder.setFragmentBytes(ptr, length: MemoryLayout<T>.size, index: index)
        }
    }
    
    public mutating func setVertexBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        setBuffer(buffer, stage: .vertex, offset: offset, index: index)
    }
    
    public mutating func setFragmentBuffer(_ buffer: Buffer, offset: Int, index: Int) {
        setBuffer(buffer, stage: .fragment, offset: offset, index: index)
    }
    
    public mutating func setVertexTexture(_ texture: Texture, index: Int) {
        setTexture(texture, stage: .vertex, index: index)
    }
    
    public mutating func setFragmentTexture(_ texture: Texture, index: Int) {
        setTexture(texture, stage: .vertex, index: index)
    }
    
    static func to(commandBuffer: MTLCommandBuffer, renderPassDescriptor: MTLRenderPassDescriptor) -> Self {
        guard let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor) else {
            fatalError("makeRenderCommandEncoder(descriptor:) returned nil")
        }
        
        return Self(encoder: encoder)
    }
    
    private mutating func setBuffer(_ buffer: Buffer, stage: RenderStage, offset: Int, index: Int) {
        guard let materialized = buffer.materialized else {
            fatalError("RenderPass bound a buffer that wasn't materialized")
        }
        
        let targetOffset = materialized.offset + offset
        
        let slot = RenderPassResourceBindingSlot(stage: stage, index: index)
        let newValue = RenderPassBufferBindingValue(buffer: materialized.buffer, offset: materialized.offset + targetOffset)
        
        if let oldValue = boundBuffers[slot] {
            if oldValue.buffer !== newValue.buffer {
                bind(newValue, to: slot)
            } else if oldValue.offset != newValue.offset {
                bind(newValue, to: slot, onlyOffset: true)
            }
        } else {
            bind(newValue, to: slot)
        }
    }
    
    private mutating func bind(_ value: RenderPassBufferBindingValue, to slot: RenderPassResourceBindingSlot, onlyOffset: Bool = false) {
        boundBuffers[slot] = value
        
        switch slot.stage {
        case .vertex:
            if onlyOffset {
                encoder.setVertexBufferOffset(value.offset, index: slot.index)
            } else {
                encoder.setVertexBuffer(value.buffer, offset: value.offset, index: slot.index)
            }
        case .fragment:
            if onlyOffset {
                encoder.setFragmentBufferOffset(value.offset, index: slot.index)
            } else {
                encoder.setFragmentBuffer(value.buffer, offset: value.offset, index: slot.index)
            }
        }
    }
    
    private mutating func setTexture(_ texture: Texture, stage: RenderStage, index: Int) {
        let slot = RenderPassResourceBindingSlot(stage: stage, index: index)
        
        if let oldTexture = boundTextures[slot], oldTexture == texture {
            // do nothing
        } else {
            let mtlTexture = texture.mtlTexture
            
            boundTextures[slot] = texture
            
            switch slot.stage {
            case .vertex:
                encoder.setVertexTexture(mtlTexture, index: index)
            case .fragment:
                encoder.setFragmentTexture(mtlTexture, index: index)
            }
        }
    }
}


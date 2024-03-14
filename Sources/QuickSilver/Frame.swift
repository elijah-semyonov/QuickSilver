import Foundation
import Metal

public final class Frame {
    private let instance: Instance
    private var passes: [Pass] = []
    private let framesContext: FramesContext
    
    init(instance: Instance, framesContext: FramesContext?) {
        self.instance = instance
                
        self.framesContext = FramesContext(instance: instance)
    }
    
    public func addRenderPass(
        named name: String? = nil,
        renderTarget: RenderTarget,
        recordUsage: (borrowing RenderResourceUsageRecorder) -> Void,
        encodeCommands: @escaping (inout RenderCommandEncoder) -> Void
    ) {
        passes.append(
            RenderPass(
                index: passes.count,
                renderTarget: renderTarget,
                name: name,
                recordUsage: recordUsage,
                encodeCommands: encodeCommands
            )
        )
    }
    
    public func addCPUPass(
        named name: String? = nil,
        recordUsage: (borrowing CPUResourceUsageRecorder) -> Void,
        invoke: @escaping (borrowing CPUResources) -> Void
    ) {
        passes.append(
            CPUPass(
                index: passes.count,
                name: name,
                recordUsage: recordUsage,
                invoke: invoke
            )
        )
    }
    
    public func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Texture {        
        .texture2D(width: width, height: height, pixelFormat: pixelFormat)
    }
    
    public func makeBuffer() -> Buffer {
        fatalError()
    }
    
    func execute(capture: Bool) async {
        for pass in passes {
            pass.updateResourceUsage()
        }
        
        var passes = Set(passes.map { PassHashableWrapper.wrapping($0) })
        var levels: [Set<PassHashableWrapper>] = []
        var resolvedResources: Set<Resource> = []
        
        while true {
            var currentLevel: Set<PassHashableWrapper> = []
            var levelResolvedResources: Set<Resource> = []
            
            for wrapper in passes {
                let resolved = wrapper.pass.allResourcesSatisfy(kind: .read) { resource in
                    resolvedResources.contains(resource)
                }
                
                if resolved {
                    currentLevel.insert(wrapper)
                    
                    wrapper.pass.forEachResource(ofKind: .written) { resource in
                        levelResolvedResources.insert(resource)
                    }
                }
            }
            
            for resource in levelResolvedResources {
                resolvedResources.insert(resource)
            }
            
            for pass in currentLevel {
                passes.remove(pass)
                currentLevel.insert(pass)
            }
            
            if currentLevel.isEmpty {
                break
            } else {
                levels.append(currentLevel)
            }
        }
        
        precondition(passes.count == 0)
        
        for resource in resolvedResources {
            switch resource {
            case .buffer(let buffer):
                fatalError("\(buffer)")
            case .texture(let texture):
                switch texture.impl {
                case .deferred(let deferredTexture):
                    let descriptor = MTLTextureDescriptor()
                    
                    descriptor.storageMode = deferredTexture.descriptor.storageMode
                    descriptor.usage = deferredTexture.descriptor.usage
                    descriptor.pixelFormat = deferredTexture.descriptor.pixelFormat
                    switch deferredTexture.descriptor.type {
                    case .texture2D(let width, let height):
                        descriptor.width = width
                        descriptor.height = height
                    }
                    
                    guard let materialized = instance.device.makeTexture(descriptor: descriptor) else {
                        fatalError("Failed to allocate texture described by \(deferredTexture.descriptor)")
                    }
                    
                    deferredTexture.materialized = materialized
                }
            }
        }
        
        let captureManager = MTLCaptureManager.shared()
                
        if (capture) {
            let captureDescriptor = MTLCaptureDescriptor()
            captureDescriptor.captureObject = instance.mainCommandQueue
            
            do {
                try captureManager.startCapture(with: captureDescriptor)
            } catch {
                print("Failed to capture. \(error.localizedDescription)")
            }
        }
        
        var commandBuffer: MTLCommandBuffer?
        
        for level in levels {
            for pass in level {
                await pass.pass.run(using: &commandBuffer, commandQueue: instance.mainCommandQueue)
            }
        }
        
        if let commandBuffer {
            await commandBuffer.commitAndAwaitUntilCompleted()
        }
        
        if captureManager.isCapturing {
            captureManager.stopCapture()
        }
    }
}

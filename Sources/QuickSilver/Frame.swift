import Foundation
import Metal

public final class Frame {
    private let instance: Instance
    private var passes: [PassId: Pass] = [:]
    private let framesContext: FramesContext
    private var nextPassId: PassId {
        PassId(passes.count)
    }
    
    private subscript(_ id: PassId) -> Pass {
        guard let pass = passes[id] else {
            fatalError("No pass with id \(id.value)")
        }
        
        return pass
    }
    
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
        let id = nextPassId
        
        passes[id] =
            RenderPass(
                id: id,
                renderTarget: renderTarget,
                name: name,
                recordUsage: recordUsage,
                encodeCommands: encodeCommands
            )
    }
    
    public func addCPUPass(
        named name: String? = nil,
        recordUsage: (borrowing CPUResourceUsageRecorder) -> Void,
        invoke: @escaping (borrowing CPUResources) -> Void
    ) {
        let id = nextPassId
        
        passes[id] =
            CPUPass(
                id: id,
                name: name,
                recordUsage: recordUsage,
                invoke: invoke
            )
    }
    
    public func makeTexture(width: Int, height: Int, pixelFormat: MTLPixelFormat) -> Texture {        
        .texture2D(width: width, height: height, pixelFormat: pixelFormat)
    }
    
    public func makeBuffer() -> Buffer {
        fatalError()
    }
    
    func execute() async {
        for pass in passes.values {
            pass.updateResourceUsage()
        }
        
        // ids of passes that haven't been resolved yet
        var unresolvedPassIds = Set(passes.map { $0.key })
        
        // array of sets of ids, each subsequent set of passes depend on previous
        var resolvedLevels: [Set<PassId>] = []
        
        // Resources and PassId of the last pass that wrote to it
        var resolvedResourcesWrites: [Resource: ResourceWrite] = [:]
        
        // Drain passes until all of them are resolved, or we are in the point where none of the remaining passes can be resolved
        while unresolvedPassIds.count > 0 {
            // All pass ids on current dependency level
            var level: Set<PassId> = []
            
            // Resources that are written on currently resolved level
            var levelResolvedResources: [Resource: PassId] = [:]
            
            // Iterate all remaining passes, and in case all of the resources they have read previously are already written insert the pass into
            // current level, and add their written resource to the resolved resources dictionary
            for passId in unresolvedPassIds {
                let pass = self[passId]
                
                let resolved = pass.allReadResourceSatisfy { resource in
                    resolvedResourcesWrites[resource] != nil
                }
                                
                if resolved {
                    // Reads of current pass
                    var reads: [Resource: PassId] = [:]
                    
                    pass.forEachReadResource { resource in
                        guard let write = resolvedResourcesWrites[resource] else {
                            preconditionFailure()
                        }
                        
                        reads[resource] = write.passId
                    }
                    
                    prepareSyncPoints(for: passId, reads: reads)
                    
                    level.insert(passId)
                    
                    pass.forEachWrittenResource { resource in
                        levelResolvedResources[resource] = passId
                    }
                }
            }
            
            // Add all resources resolved on this level to written set
            for (resource, passId) in levelResolvedResources {
                resolvedResourcesWrites[resource] = self[passId].resourceWrite(for: resource)
            }
            
            // Remove unresolved resources and add passes to current level
            for passId in level {
                unresolvedPassIds.remove(passId)
                level.insert(passId)
            }
            
            // If no passes were resolved on this iteration, break
            if level.isEmpty {
                break
            } else {
                resolvedLevels.append(level)
            }
        }
        
        // If break happened before all passes were resolved, it means that some of the passes depend on the resources that were
        // never written, that's illegal
        precondition(unresolvedPassIds.count == 0)
        
        // Materialize all resources
        for resource in resolvedResourcesWrites.keys {
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
                        preconditionFailure()
                    }
                    
                    deferredTexture.materialized = materialized
                }
            }
        }
        
        let passExecutionContext = PassExecutionContext(passesExecutionCommandBuffers: [:])
        
        for level in resolvedLevels {
            for passId in level {
                await self[passId].execute(in: passExecutionContext)
            }
        }
    }
    
    private func prepareSyncPoints(for passId: PassId, reads: [Resource: PassId]) {
        guard let pass = passes[passId] else {
            preconditionFailure()
        }
        
        for (resource, dependencyPassId) in reads {
            guard let dependencyPass = passes[passId] else {
                preconditionFailure()
            }
        }
    }
}

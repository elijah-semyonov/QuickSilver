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
    
    @MainActor
    public static func initialize(libraryBundle: Bundle? = nil) -> MetalBackend {
        if let shared {
            return shared
        }
        
        let shared = MetalBackend(libraryBundle: libraryBundle)
        self.shared = shared
        return shared
    }
    
    public func executeFrame(_ frame: (FrameScope) -> Void) {
        
    }
    
    public func executePresentableFrame(layer: CAMetalLayer, _ frame: (PresentableFrameScope) -> Void) {
        
    }
}

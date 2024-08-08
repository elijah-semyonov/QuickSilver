//
//  MetalContext.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//
import Metal

class MetalContext {
    @MainActor
    static let shared: MetalContext = MetalContext()
    
    let device: MTLDevice
    
    let library: MTLLibrary
    
    let commandQueue: MTLCommandQueue
    
    init() {
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("Metal is not supported on this device.")
        }
        
        let library: MTLLibrary
        
        do {
            library = try device.makeDefaultLibrary(bundle: .main)
        } catch {
            fatalError("Failed to load Metal library. \(error)")
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create Metal command queue.")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.library = library
    }
}

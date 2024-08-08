//
//  MetalContext.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

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
        
        guard let library = device.makeDefaultLibrary(bundle: .main) else {
            fatalError("Failed to create Metal library.")
        }
        
        guard let commandQueue = device.makeCommandQueue() else {
            fatalError("Failed to create Metal command queue.")
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.library = library
    }
}

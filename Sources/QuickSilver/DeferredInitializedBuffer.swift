//
//  DeferredInitializedBuffer.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 25/08/2024.
//

import Foundation

protocol DeferredInitializedBufferSource {
    var alignment: Int { get }
    
    var byteCount: Int { get }
    
    func withUnsafeRawBufferPointer<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R
}

struct DeferredInitializedBufferArraySource<T>: DeferredInitializedBufferSource {
    let array: [T]
    
    var alignment: Int {
        MemoryLayout<T>.alignment
    }
    
    var byteCount: Int {
        MemoryLayout<T>.stride * array.count
    }
    
    func withUnsafeRawBufferPointer<R>(_ body: (UnsafeRawBufferPointer) throws -> R) rethrows -> R {
        let result = try array.withContiguousStorageIfAvailable { buffer in
            try body(UnsafeRawBufferPointer(buffer))
        }
        
        guard let result else {
            fatalError("Failed to copy buffer")
        }
        
        return result
    }
}

class DeferredInitializedBuffer: InferredBuffer {
    let name: String
    
    let source: any DeferredInitializedBufferSource
    
    var asTagged: TaggedInferredBuffer {
        .deferredInitialized(self)
    }
    
    init<T>(
        name: String?,
        array: [T]
    ) {
        self.name = name ?? "DeferredInitializedBuffer \(UUID())"
        source = DeferredInitializedBufferArraySource(array: array)
    }
}

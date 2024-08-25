//
//  DeferredBuffer.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 25/08/2024.
//

class DeferredBuffer: InferredBuffer {
    let name: String
    
    var asTagged: TaggedInferredBuffer {
        fatalError()
    }
    
    init(
        name: String
    ) {
        self.name = name
    }
}

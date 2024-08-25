//
//  InferredBuffer.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 25/08/2024.
//

protocol InferredBuffer {
    var asTagged: TaggedInferredBuffer { get }
}

enum TaggedInferredBuffer {
    case deferredInitialized(DeferredInitializedBuffer)
}

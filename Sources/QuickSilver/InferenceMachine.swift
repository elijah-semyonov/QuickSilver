//
//  InferenceMachine.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 18/08/2024.
//

protocol Inference {
    var target: AnyInferredValue { get }
    
    func resolve() throws -> InferenceResolutionResult
}

struct InferenceError: Error {
    let message: String
}

struct SameAsInference<T: Hashable>: Inference {
    var target: AnyInferredValue {
        typedTarget
    }

    let typedTarget: TypedInferredValue<T>
    let source: TypedInferredValue<T>
    
    func resolve() throws -> InferenceResolutionResult {
        try typedTarget.intersect(with: source)
    }
}

enum InferenceResolutionResult {
    case none
    
    case partial
    
    case complete
}

class InferenceMachine {
    /// An array of all unresolved values
    private var values: Set<AnyInferredValue> = []
    
    /// Dictionary of values keying an array of inferences that are based on this value
    private var sourceToInferences: [AnyInferredValue: [Inference]] = [:]
    
    /// Dictionary of values keying an array of inferrences that affect this value
    private var targetToInferences: [AnyInferredValue: [Inference]] = [:]
    
    func inferValues() throws {
        var candidates: Set<AnyInferredValue> = []
        
        values = values.filter { value in
            let isInferred = value.isInferred
            
            if isInferred {
                targetToInferences.removeValue(forKey: value)
                
                if let inferences = sourceToInferences[value] {
                    for inference in inferences {
                        candidates.insert(inference.target)
                    }
                }
            }
            
            return !isInferred
        }
                               
        while !values.isEmpty {            
            var hasAnyProgress = false
            
            var nextPassCandidates: Set<AnyInferredValue> = []
            
            let sequence: any Sequence<AnyInferredValue>
            if candidates.isEmpty {
                sequence = values
            } else {
                sequence = candidates
            }
            
            for candidate in sequence {
                if try inferCandidate(candidate, nextPassCandidates: &nextPassCandidates) {
                    hasAnyProgress = true
                }
            }
            
            if !hasAnyProgress {
                fatalError("Inference constraints are not enough to infer all values.")
            }
            
            candidates = nextPassCandidates
        }
    }
    
    func same<T>(_ lhs: TypedInferredValue<T>, as rhs: TypedInferredValue<T>) {
        values.insert(lhs)
        values.insert(rhs)
        
        insertInference(
            source: rhs,
            SameAsInference(typedTarget: lhs, source: rhs)
        )
        
        insertInference(
            source: lhs,
            SameAsInference(typedTarget: rhs, source: lhs)
        )
    }
    
    private func insertInference<I: Inference>(source: AnyInferredValue, _ inference: I) {
        sourceToInferences[source, default: []].append(inference)
        targetToInferences[inference.target, default: []].append(inference)
    }
        
    private func inferCandidate(_ candidate: AnyInferredValue, nextPassCandidates: inout Set<AnyInferredValue>) throws -> Bool {
        var hasAnyProgress = false
        
        if let inferences = targetToInferences[candidate] {
            for inference in inferences {
                let result = try inference.resolve()
                
                switch result {
                case .complete:
                    values.remove(candidate)                                        
                    insertCandidates(&nextPassCandidates, dependingOn: candidate)
                    hasAnyProgress = true
                case .partial:
                    insertCandidates(&nextPassCandidates, dependingOn: candidate)
                    hasAnyProgress = true                    
                case .none:
                    break
                }
            }
        }
        
        return hasAnyProgress
    }
    
    private func insertCandidates(_ candidates: inout Set<AnyInferredValue>, dependingOn value: AnyInferredValue) {
        if let inferences = sourceToInferences[value] {
            for inference in inferences {
                candidates.insert(inference.target)
            }
        }
    }
}

class AnyInferredValue: Hashable {
    var isInferred: Bool {
        return false
    }
    
    static func == (lhs: AnyInferredValue, rhs: AnyInferredValue) -> Bool {
        lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}

class TypedInferredValue<T: Hashable>: AnyInferredValue {
    enum State {
        case unresolved
        case possible(Set<T>)
        case resolved(T)
    }
    
    var state: State
    var value: T {
        if case .resolved(let value) = state {
            return value
        } else {
            fatalError("Value is not resolved, current state is \(state)")
        }
    }
    
    init(oneOf: [T]) {
        state = .possible(Set(oneOf))
    }
    
    init(ofType type: T.Type = T.self) {
        state = .unresolved
    }
    
    init(_ value: T) {
        state = .resolved(value)
    }
    
    override var isInferred: Bool {
        if case .resolved = state {
            true
        } else {
            false
        }
    }
    
    func intersect(with other: TypedInferredValue) throws -> InferenceResolutionResult {
        switch state {
        case .unresolved:
            switch other.state {
            case .unresolved:
                return .none
                
            case .possible(let otherSet):
                state = .possible(otherSet)
                return .partial
                
            case .resolved(let otherValue):
                state = .resolved(otherValue)
                return .complete
            }
            
        case .possible(let set):
            switch other.state {
            case .unresolved:
                other.state = .possible(set)
                return .partial
                
            case .possible(let otherSet):
                let intersection = set.intersection(otherSet)
                
                switch intersection.count {
                case 0:
                    throw InferenceError(message: "Possible sets \(set) and \(otherSet) do not intersect")
                case 1:
                    let value = intersection.first!
                    state = .resolved(value)
                    other.state = .resolved(value)
                    return .complete
                default:
                    state = .possible(intersection)
                    other.state = .possible(intersection)
                    return .partial
                    
                }
                
            case .resolved(let otherValue):
                if set.contains(otherValue) {
                    state = .resolved(otherValue)
                    return .complete
                } else {
                    throw InferenceError(message: "Resolved value \(otherValue) it not in the set \(set)")
                }
            }
            
        case .resolved(let value):
            switch other.state {
            case .unresolved:
                other.state = .resolved(value)
                return .complete
                
            case .possible(let otherSet):
                if otherSet.contains(value) {
                    other.state = .resolved(value)
                    return .complete
                } else {
                    throw InferenceError(message: "Resolved value \(value) it not in the set \(otherSet)")
                }
                
            case .resolved(let otherValue):
                if otherValue != value {
                    throw InferenceError(message: "Resolved values \(value) and \(otherValue) do not match")
                }
                
                return .complete
            }
        }
    }
}

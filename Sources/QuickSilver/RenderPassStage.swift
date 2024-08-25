//
//  RenderPassStage.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 25/08/2024.
//

public enum RenderPassStage: UInt8, CaseIterable, Hashable {
    case vertex = 0
    
    case fragment = 1
    
    var asBitmask: UInt8 {
        1 << rawValue
    }
}

public struct RenderPassStages: OptionSet {
    public typealias RawValue = RenderPassStage.RawValue
    
    static var vertex: Self {
        .init(RenderPassStage.vertex)
    }
    
    static var fragment: Self {
        .init(RenderPassStage.fragment)
    }
    
    public var rawValue: RawValue
    
    public init(rawValue: RawValue) {
        self.rawValue = rawValue
    }
    
    public init(_ stage: RenderPassStage) {
        self.init(rawValue: stage.asBitmask)
    }
    
    func forEach(_ body: (RenderPassStage) -> Void) {
        for stage in RenderPassStage.allCases where contains(Self(stage)) {
            body(stage)
        }
    }
}

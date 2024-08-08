//
//  DrawScope.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

public protocol DrawScope {
    func renderPass(_ body: (RenderPassScope) -> Void)
}

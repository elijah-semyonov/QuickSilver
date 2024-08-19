//
//  StoreAction.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 11/08/2024.
//

public enum StoreAction {    
    case store
    
    case multisampleResolve(target: Texture)
    
    case storeAndMultisampleResolve(target: Texture)
}

//
//  TextureDataArrangement.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 19/08/2024.
//

protocol TextureDataArrangement {
    var asTagged: TaggedTextureDataArrangement { get }
}

public struct TextureDataArrangement1D: TextureDataArrangement {
    public let width: Int
    
    public let count: Int
    
    var asTagged: TaggedTextureDataArrangement {
        .oneDimensional(self)
    }
    
    public init(width: Int, count: Int) {
        precondition(width >= 1)
        precondition(count >= 1)
        
        self.width = width
        self.count = count
    }
}

public struct TextureDataArrangement2D {
    public let width: Int
    
    public let height: Int
    
    public let count: Int
    
    var asTagged: TaggedTextureDataArrangement {
        .twoDimensional(self)
    }
    
    public init(width: Int, height: Int, count: Int) {
        precondition(width >= 1)
        precondition(height >= 1)
        precondition(count >= 1)
        
        self.width = width
        self.height = height
        self.count = count
    }
}

public struct TextureDataArrangement3D {
    public let width: Int
    
    public let height: Int
    
    public let depth: Int
    
    var asTagged: TaggedTextureDataArrangement {
        .threeDimensional(self)
    }
    
    public init(width: Int, height: Int, depth: Int) {
        precondition(width >= 1)
        precondition(height >= 1)
        precondition(depth >= 1)
        
        self.width = width
        self.height = height
        self.depth = depth
    }
}

public struct TextureDataArrangementCube {
    public let size: Int
    
    public let count: Int
    
    var asTagged: TaggedTextureDataArrangement {
        .cube(self)
    }
    
    public init(size: Int, count: Int) {
        precondition(size >= 1)
        precondition(count >= 1)
        
        self.size = size
        self.count = count
    }
}

enum TaggedTextureDataArrangement {
    case oneDimensional(TextureDataArrangement1D)
    
    case twoDimensional(TextureDataArrangement2D)
    
    case threeDimensional(TextureDataArrangement3D)
    
    case cube(TextureDataArrangementCube)
}

//
//  Region.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 08/08/2024.
//

public struct Region {
    static let undefined: Int = -1
    
    public let x: Int
    public let y: Int
    public let z: Int
    
    public let width: Int
    public let height: Int
    public let depth: Int
    
    init(
        x: Int = 0,
        y: Int = 0,
        z: Int = 0,
        width: Int = 1,
        height: Int = 1,
        depth: Int = 1
    ) {
        precondition(height >= 1)
        precondition(depth >= 1)
        
        self.x = x
        self.y = y
        self.z = z
        self.width = width
        self.height = height
        self.depth = depth
    }
    
    static func region1D(x: Int = 0, width: Int = Self.undefined) -> Self {
        .init(x: x, width: width)
    }
    
    static func region2D(
        x: Int = 0,
        y: Int = 0,
        width: Int = Self.undefined,
        height: Int = Self.undefined
    ) -> Self {
        .init(x: x, y: y, width: width, height: height)
    }
    
    static func region3D(
        x: Int = 0,
        y: Int = 0,
        z: Int = 0,
        width: Int = Self.undefined,
        height: Int = Self.undefined,
        depth: Int = Self.undefined
    ) -> Self {
        .init(x: x, y: y, z: z, width: width, height: height, depth: depth)
    }
}

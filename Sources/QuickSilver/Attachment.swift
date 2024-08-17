//
//  Attachment.swift
//  QuickSilver
//
//  Created by Elijah Semyonov on 11/08/2024.
//

public struct Attachment<ClearValue> {
    public let texture: Texture
    public let loadAction: LoadAction<ClearValue>?
    public let storeAction: StoreAction?
    
    public init(
        texture: Texture,
        loadAction: LoadAction<ClearValue>?,
        storeAction: StoreAction?
    ) {
        self.texture = texture
        self.storeAction = storeAction
        self.loadAction = loadAction
    }
    
    public static func texture(_ texture: Texture, clearedWith clearValue: ClearValue) -> Self {
        .init(texture: texture, loadAction: .clear(clearValue), storeAction: nil)
    }
}

public struct ClearColor {
    public static var opaqueBlack: Self {
        .init(red: 0, green: 0, blue: 0, alpha: 1)
    }
    
    public static var transparentBlack: Self {
        .init(red: 0, green: 0, blue: 0, alpha: 0)
    }
    
    public let red: Double
    public let green: Double
    public let blue: Double
    public let alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

public typealias ColorAttachment = Attachment<ClearColor>

public struct ClearDepth: ExpressibleByFloatLiteral {
    public static var zero: Self {
        0.0
    }
    
    public static var one: Self {
        1.0
    }
    
    public let value: Double
    
    public init(_ value: Double) {
        self.value = value
    }
    
    public init(floatLiteral value: FloatLiteralType) {
        self.value = Double(value)
    }
}

public typealias DepthAttachment = Attachment<ClearDepth>

public extension DepthAttachment {
    init(
        texture: Texture
    ) {
        self = .init(texture: texture, loadAction: .clear(.zero), storeAction: nil)
    }
}

public struct ClearStencil: ExpressibleByIntegerLiteral {
    public static var zero: Self {
        0
    }
    
    public let value: UInt32
    
    public init(_ value: UInt32) {
        self.value = value
    }
    
    public init(integerLiteral value: IntegerLiteralType) {
        self.value = UInt32(value)
    }
}

public typealias StencilAttachment = Attachment<ClearStencil>

public extension StencilAttachment {
    init(
        texture: Texture
    ) {
        self = .init(texture: texture, loadAction: .clear(.zero), storeAction: nil)
    }
}

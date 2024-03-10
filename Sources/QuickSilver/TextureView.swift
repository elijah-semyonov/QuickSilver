import Foundation

public protocol TexelComponent {
}

extension UInt8: TexelComponent {
}

public enum FourComponentsOrder {
    case rgba
    case bgra
}

public struct FourComponentsTexel<Component> where Component: TexelComponent {
    let ptr: UnsafePointer<Component>
    let order: FourComponentsOrder
    
    public var r: Component {
        switch order {
        case .bgra:
            ptr[2]
        case .rgba:
            ptr[0]
        }
    }
    
    public var g: Component {
        ptr[1]
    }
    
    public var b: Component {
        switch order {
        case .bgra:
            ptr[0]
        case .rgba:
            ptr[2]
        }
    }
    
    public var a: Component {
        ptr[3]
    }
}

public struct FourComponentsTextureReadView<Component>: ~Copyable where Component: TexelComponent {
    let ptr: UnsafePointer<Component>
    let width: Int
    let height: Int
    let depth: Int
    let slice: Int
    let order: FourComponentsOrder
}

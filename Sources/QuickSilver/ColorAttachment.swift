import Foundation

public struct ColorAttachment {
    public let texture: Texture
    public let storeAction: ColorStoreAction
    public let loadAction: LoadAction<ClearColor>
    
    public init(texture: Texture, storeAction: ColorStoreAction, loadAction: LoadAction<ClearColor>) {
        self.texture = texture
        self.storeAction = storeAction
        self.loadAction = loadAction
    }
    
    public func updateTextureUsage() {
        let stores = switch storeAction {
        case .storeAction(let action):
            switch action {
            case .store:
                true
            case .dontCare:
                false
            }
        case .multisampleResolve:
            false
        }
        
        let loads = switch loadAction {
        case .clear:
           false
        case .load:
            true
        case .dontCare:
            false
        }
        
        texture.useAsRenderTarget(loadsOrStores: loads || stores)
    }
}

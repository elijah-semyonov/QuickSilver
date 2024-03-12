import Foundation

public struct StencilAttachment {
    public let texture: Texture
    public let loadAction: LoadAction<StencilValue>
    public let storeAction: StoreAction
    
    public func updateTextureUsage() {
        let loads = switch loadAction {
        case .clear:
            false
        case .load:
            true
        case .dontCare:
            false
        }
        
        let stores = storeAction == .store
        
        texture.useAsRenderTarget(loadsOrStores: loads || stores)
    }
}

import Foundation

public struct DepthAttachment {
    public let texture: Texture
    public let storeAction: StoreAction
    public let loadAction: LoadAction<DepthValue>
    
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

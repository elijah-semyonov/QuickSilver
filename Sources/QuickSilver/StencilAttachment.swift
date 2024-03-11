import Foundation

public struct StencilAttachment {
    public let texture: Texture
    public let loadAction: LoadAction<StencilValue>
    public let storeAction: StoreAction
    
    public func updateTextureUsage() {
        texture.useAsRenderTarget(loadsOrStores: storeAction == .store || loadAction.isLoadAction)
    }
}

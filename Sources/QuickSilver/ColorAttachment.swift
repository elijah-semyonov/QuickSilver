import Foundation

public struct ColorAttachment {
    public let texture: Texture
    public let storeAction: ColorStoreAction
    public let loadAction: LoadAction<ClearColor>
    
    public func updateTextureUsage() {
        texture.useAsRenderTarget(loadsOrStores: storeAction.isStoreAction || loadAction.isLoadAction)
    }
}

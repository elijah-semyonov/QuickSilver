import Foundation

public struct DepthAttachment {
    public let texture: Texture
    public let storeAction: StoreAction
    public let loadAction: LoadAction<DepthValue>
}

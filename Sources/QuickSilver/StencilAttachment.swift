public struct StencilAttachment {
    public let texture: Texture
    public let loadAction: LoadAction<StencilValue>
    public let storeAction: StoreAction
}

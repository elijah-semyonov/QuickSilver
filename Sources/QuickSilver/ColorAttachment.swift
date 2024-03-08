public struct ColorAttachment {
    public let texture: Texture
    public let storeAction: ColorStoreAction
    public let loadAction: LoadAction<ClearColor>
}

public struct CPUPassResourceUsageRecorder: ~Copyable {
    let pass: CPUPass
    
    public func readTexture(_ texture: Texture) {
        pass.readResource(.texture(texture))
    }
    
    public func writeTexture(_ texture: Texture) {
        pass.writeResource(.texture(texture))
    }
}

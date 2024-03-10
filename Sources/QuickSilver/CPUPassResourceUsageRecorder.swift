public struct CPUPassResourceUsageRecorder: ~Copyable {
    let pass: CPUPass
    
    public func accessTexture(_ texture: Texture) {
        texture.usages.append(.cpuPassAccess(pass))
    }
}

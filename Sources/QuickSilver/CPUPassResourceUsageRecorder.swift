public struct CPUPassResourceUsageRecorder: ~Copyable {
    let pass: CPUPass    
    let trackers: FrameResourceUsageTrackers
    
    public func accessTexture(_ texture: Texture) {
        trackers[texture].usages.append(.cpuAccess(pass))
    }
}

import Foundation

public struct RenderPassResourceUsageRecorder: ~Copyable {
    let pass: RenderPass
    let trackers: FrameResourceUsageTrackers
    
    
    public func readTexture(_ texture: Texture, stage: RenderStage) {
        trackers[texture].usages.append(.read(pass, stage: stage))
    }
}

import Foundation

public struct RenderPassResourceUsageRecorder {
    let pass: RenderPass
    
    public func produceSideEffects() {
        pass.produceSideEffects()
    }
    
    public func readTexture(_ texture: Texture, stage: RenderStage) {
        pass.readResource(resource: .texture(texture), at: stage)
    }
    
    public func writeTexture(_ texture: Texture, stage: RenderStage) {
        pass.writeResource(resource: .texture(texture), at: stage)
    }
}

import Foundation

public struct RenderResourceUsageRecorder {
    let pass: RenderPass        
    
    public func readTexture(_ texture: Texture, stage: RenderStage) {
        pass.readResource(resource: .texture(texture), at: stage)
    }
    
    public func writeTexture(_ texture: Texture, stage: RenderStage) {
        pass.writeResource(resource: .texture(texture), at: stage)
    }
}

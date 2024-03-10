import Foundation

public struct RenderPassResourceUsageRecorder {
    let pass: RenderPass
    
    public func readTexture(_ texture: Texture, stage: RenderStage) {        
        texture.usages.append(.renderPassRead(pass, stage: stage))
        pass.readResource(resource: .texture(texture), at: stage)
    }
    
    public func writeTexture(_ texture: Texture, stage: RenderStage) {
        texture.usages.append(.renderPassWrite(pass, stage: stage))
    }
}

import Foundation

enum TextureUsageRecord {
    case renderTarget(RenderPass, loads: Bool, stores: Bool)
    case read(RenderPass, stage: RenderStage)
    case write(RenderPass, stage: RenderStage)
    case cpuAccess(CPUPass)
}

import Foundation

enum TextureUsageRecord {
    case renderPassTarget(RenderPass, loads: Bool, stores: Bool)
    case renderPassRead(RenderPass, stage: RenderStage)
    case renderPassWrite(RenderPass, stage: RenderStage)
    case cpuPassAccess(CPUPass)
}

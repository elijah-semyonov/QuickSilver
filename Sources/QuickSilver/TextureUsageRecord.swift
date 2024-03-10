import Foundation

enum TextureUsageRecord {
    case renderTarget(RenderPass, loads: Bool, stores: Bool)
    case cpuAccess(CPUPass)
}

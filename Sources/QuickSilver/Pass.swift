import Foundation

enum Pass: Hashable {
    case renderPass(RenderPass)
    case cpuPass(CPUPass)
}

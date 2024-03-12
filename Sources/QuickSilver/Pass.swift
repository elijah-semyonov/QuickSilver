import Foundation

enum Pass: Hashable {
    case renderPass(RenderPass)
    case cpuPass(CPUPass)
    
    var dependsOnNothing: Bool {
        switch self {
        case .renderPass(let pass):
            pass.dependsOnNothing
        case .cpuPass(let pass):
            pass.dependsOnNothing
        }
    }
}

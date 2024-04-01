import Foundation

enum ResourceWrite {
    case cpuPass(CPUPass)
    case renderPass(RenderPass, stage: RenderStage)
    
    var passId: PassId {
        switch self {
        case .cpuPass(let pass):
            pass.id
        case .renderPass(let pass, _):
            pass.id
        }
    }
}

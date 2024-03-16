import Foundation

enum ResourceWrite {
    case cpuPass(id: PassId)
    case renderPass(id: PassId, stage: RenderStage)
    
    var passId: PassId {
        switch self {
        case .cpuPass(let id):
            id
        case .renderPass(let id, _):
            id
        }
    }
}

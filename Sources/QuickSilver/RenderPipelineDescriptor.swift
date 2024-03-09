import Foundation
import Metal

public struct RenderPipelineDescriptor: Hashable {
    let vertexFunction: Function
    let fragmentFunction: Function?
    
    let renderTarget: [RenderPipelineTarget]
}

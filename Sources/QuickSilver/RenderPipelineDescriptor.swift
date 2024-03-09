import Foundation
import Metal

public struct RenderPipelineDescriptor: Hashable {
    let vertexFunction: FunctionDescriptor
    let fragmentFunction: FunctionDescriptor?    
    let renderTarget: RenderPipelineTarget
}

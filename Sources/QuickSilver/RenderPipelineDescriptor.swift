import Foundation
import Metal

public struct RenderPipelineDescriptor: Hashable {
    public let vertexFunction: FunctionDescriptor
    public let fragmentFunction: FunctionDescriptor?
    public let renderTarget: RenderPipelineTarget
    
    public init(vertexFunction: FunctionDescriptor, fragmentFunction: FunctionDescriptor?, renderTarget: RenderPipelineTarget) {
        self.vertexFunction = vertexFunction
        self.fragmentFunction = fragmentFunction
        self.renderTarget = renderTarget
    }
}

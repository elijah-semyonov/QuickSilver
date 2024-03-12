import Foundation

public struct RenderTarget {
    public let colorAttachments: [Int: ColorAttachment]
    public let depthAttachment: DepthAttachment?
    public let stencilAttachment: StencilAttachment?
    
    var hasAnyLoad: Bool {
        let hasAnyColorLoad = colorAttachments.values.reduce(false) { partialResult, attachment in
            if case .load = attachment.loadAction {
                true
            } else {
                partialResult
            }
        }
        
        let hasDepthLoad = if let depthAttachment {
            if case .load = depthAttachment.loadAction {
                true
            } else {
                false
            }
        } else {
            false
        }
        
        let hasStencilLoad = if let stencilAttachment {
            if case .load = stencilAttachment.loadAction {
                true
            } else {
                false
            }
        } else {
            false
        }
        
        return hasAnyColorLoad || hasDepthLoad || hasStencilLoad
    }
    
    public init(colorAttachments: [Int : ColorAttachment], depthAttachment: DepthAttachment?, stencilAttachment: StencilAttachment?) {
        self.colorAttachments = colorAttachments
        self.depthAttachment = depthAttachment
        self.stencilAttachment = stencilAttachment
    }
    
    func forEachWrittenAttachmentTexture(_ closure: (Texture) -> Void) {
        for attachment in colorAttachments.values {
            switch attachment.storeAction {
            case .storeAction(let action):
                switch action {
                case .store:
                    closure(attachment.texture)
                case .dontCare:
                    break
                }
            case .multisampleResolve(let resolve):
                fatalError("\(resolve)")
            }
        }
        
        if let attachment = depthAttachment {
            switch attachment.storeAction {
            case .store:
                closure(attachment.texture)
            case .dontCare:
                break
            }
        }
        
        if let attachment = stencilAttachment {
            switch attachment.storeAction {
            case .store:
                closure(attachment.texture)
            case .dontCare:
                break
            }
        }
    }
}

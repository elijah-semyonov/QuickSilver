import XCTest
@testable import QuickSilver

final class QuickSilverTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testInitial() {
        let device = MTLCreateSystemDefaultDevice()!
        let library = try! device.makeDefaultLibrary(bundle: Bundle.module)
        
        print(library.functionNames)
        
        let instance = Instance(device: device)
        
        instance.executeFrame { frame in
            let texture = frame
            
            let renderTarget = RenderTarget(
                colorAttachments: [
                    0: ColorAttachment(texture: Texture(), storeAction: .storeAction(.store), loadAction: .clear(.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)))
                ],
                depthAttachment: nil,
                stencilAttachment: nil
            )
            
            frame.addRenderPass(renderTarget: renderTarget) { scope in  
                //scope.setRenderPipelineState(RenderPipelineState())
            }
        }
    }
}

import XCTest
@testable import QuickSilver

final class QuickSilverTests: XCTestCase {
    func testExample() throws {
        // XCTest Documentation
        // https://developer.apple.com/documentation/xctest

        // Defining Test Cases and Test Methods
        // https://developer.apple.com/documentation/xctest/defining_test_cases_and_test_methods
    }
    
    func testInitial() async throws {
        let device = MTLCreateSystemDefaultDevice()!
        let library = try device.makeDefaultLibrary(bundle: Bundle.module)
        
        print(library.functionNames)
        
        let instance = Instance(device: device, library: library)
        
        let renderPipelineState = await instance.renderPipelineState(
            describedBy: RenderPipelineDescriptor(
                vertexFunction: .named("test_vs"),
                fragmentFunction: .named("test_fs"),
                renderTarget: RenderPipelineTarget(colorAttachments: [
                    0: RenderPipelineColorAttachment(
                        pixelFormat: .bgra8Unorm_srgb,
                        isBlendingEnabled: false
                    )
                ])
            )
        )
        
        instance.executeFrame { frame in
            let texture = frame.makeTexture(width: 100, height: 100, pixelFormat: .bgra8Unorm_srgb)
            
            let renderTarget = RenderTarget(
                colorAttachments: [
                    0: ColorAttachment(
                        texture: texture,
                        storeAction: .store,
                        loadAction: .clear(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                ],
                depthAttachment: nil,
                stencilAttachment: nil
            )
            
            frame.addRenderPass(renderTarget: renderTarget) { usageRecorder in
                // empty
            } encodeCommands: { recorder in
                recorder.setRenderPipelineState(renderPipelineState)

                recorder.drawPrimitives(vertexCount: 6)
            }
            
            frame.addCPUPass { usageRecorder in
                usageRecorder.readTexture(texture)
                usageRecorder.produceSideEffects()
            } invoke: { resources in
                resources.accessTexture(texture) { texture in
                    print(texture)
                }
            }

        }
    }
}

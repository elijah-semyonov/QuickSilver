import XCTest
import QuickSilver

final class BlackBoxTests: XCTestCase {
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
            let texture0 = frame.makeTexture(width: 100, height: 100, pixelFormat: .bgra8Unorm_srgb)
            let texture1 = frame.makeTexture(width: 100, height: 100, pixelFormat: .bgra8Unorm_srgb)
            let texture2 = frame.makeTexture(width: 100, height: 100, pixelFormat: .bgra8Unorm_srgb)
            
            frame.addRenderPass(renderTarget: RenderTarget(
                colorAttachments: [
                    0: ColorAttachment(
                        texture: texture0,
                        storeAction: .store,
                        loadAction: .clear(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                ],
                depthAttachment: nil,
                stencilAttachment: nil
            )) { usageRecorder in
                // empty
            } encodeCommands: { encoder in
                encoder.setRenderPipelineState(renderPipelineState)

                encoder.drawPrimitives(vertexCount: 6)
            }
            
            frame.addRenderPass(renderTarget: RenderTarget(
                colorAttachments: [
                    0: ColorAttachment(
                        texture: texture1,
                        storeAction: .store,
                        loadAction: .clear(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                ],
                depthAttachment: nil,
                stencilAttachment: nil
            )) { usageRecorder in
                usageRecorder.readTexture(texture0, stage: .fragment)
            } encodeCommands: { encoder in
                // empty
            }
            
            frame.addRenderPass(renderTarget: RenderTarget(
                colorAttachments: [
                    0: ColorAttachment(
                        texture: texture2,
                        storeAction: .store,
                        loadAction: .clear(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
                ],
                depthAttachment: nil,
                stencilAttachment: nil
            )) { usageRecorder in
                usageRecorder.readTexture(texture0, stage: .fragment)
            } encodeCommands: { encoder in
                // empty
            }
            
            frame.addCPUPass { usageRecorder in
                usageRecorder.readTexture(texture1)
                usageRecorder.readTexture(texture2)
            } invoke: { resources in
                // empty
            }
        }
    }
}

import XCTest
@testable import QuickSilver

final class QuickSilverTests: XCTestCase {
    @MainActor
    func testSimple() throws {
        let backend = MetalBackend.initialize(libraryBundle: .module)
        
        backend.executeFrame { frame in
            let texture = frame.texture()
            
            frame.renderPass(colorAttachments: [
                .texture(texture, clearedWith: .opaqueBlack)
            ]) { pass in
                
            }
        }
    }
}

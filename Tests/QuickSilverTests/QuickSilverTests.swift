import XCTest
@testable import QuickSilver

final class QuickSilverTests: XCTestCase {
    @MainActor
    func testSimple() throws {
        let backend = MetalBackend.initialize(libraryBundle: .module)
                
    }
}

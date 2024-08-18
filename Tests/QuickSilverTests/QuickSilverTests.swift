import XCTest
@testable import QuickSilver

final class QuickSilverTests: XCTestCase {
    @MainActor
    func testSimple() throws {
        let backend = MetalBackend.initialize(libraryBundle: .module)
                
    }
    
    @MainActor
    func testInferenceMachine() throws {
        let inferenceMachine = InferenceMachine()
        
        let a = TypedInferredValue(ofType: Int.self)
        let b = TypedInferredValue(oneOf: [1, 2, 3, 4])
        let c = TypedInferredValue(ofType: Int.self)
        let d = TypedInferredValue(oneOf: [1, 6, 8])
        
        inferenceMachine.same(c, as: b)
        inferenceMachine.same(d, as: b)
        inferenceMachine.same(b, as: a)
        try inferenceMachine.inferValues()
        
        XCTAssertEqual(a.value, 1)
        XCTAssertEqual(b.value, 1)
        XCTAssertEqual(c.value, 1)
        XCTAssertEqual(d.value, 1)
    }
}

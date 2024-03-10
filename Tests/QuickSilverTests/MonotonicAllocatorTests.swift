import XCTest
@testable import QuickSilver

final class MonotonicAllocatorTests: XCTestCase {
    func test() throws {
        let allocator = MonotonicAllocator(byteCount: .mebibytes(5))
        
        let allocations = (0...10).map { _ in
            allocator.allocate(Int.self)
        }
        
        for i in 0..<allocations.count - 1 {
            let diff = allocations[i].distance(to: allocations[i + 1])
            
            XCTAssertEqual(diff, 1)
        }
        
        allocator.reset()
        let intPtr = UnsafeRawPointer(allocator.allocate(Int.self))
        let doublePtr = UnsafeRawPointer(allocator.allocate(Double.self))
        
        XCTAssertEqual(intPtr.distance(to: doublePtr), MemoryLayout<UnsafeRawPointer>.size)
        
        allocator.reset()
        let queue = DispatchQueue(label: "Test queue", attributes: .concurrent)
        
        var pointers = [Int](repeating: 0, count: 1000)
        
        let dispatchGroup = DispatchGroup()
        for i in 0..<pointers.count {
            dispatchGroup.enter()
            queue.async {
                pointers[i] = Int(bitPattern: UnsafeRawPointer(allocator.allocate(byteCount: .random(in: 1...5) * 8, alignment: .random(in: 1...2) * 4)))
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.wait()
                
        let pointersSet = Set(pointers)
        
        XCTAssertEqual(pointersSet.count, pointers.count)
    }
}

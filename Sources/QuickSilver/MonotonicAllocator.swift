import Foundation
import Atomics

final class MonotonicAllocator: @unchecked Sendable, Allocator {
    private let byteCount: Int
    private let alignment: Int
    private let offset = ManagedAtomic(0)
    private let ptr: UnsafeMutableRawPointer
    
    init(byteCount: BytesCount, alignment: Int = MemoryLayout<UnsafeRawPointer>.size) {
        self.byteCount = byteCount.value
        self.alignment = alignment
        ptr = .allocate(byteCount: self.byteCount, alignment: alignment)
    }
    
    deinit {
        ptr.deallocate()
    }
    
    func allocate(size: Int, alignment: Int) -> UnsafeMutableRawPointer {
        precondition(self.alignment % alignment == 0)
        
        var currentOffset: Int
        var newOffset: Int
        var padding: Int
        
        repeat {
            currentOffset = offset.load(ordering: .relaxed)
            let alignmentMask = alignment - 1
            padding = (alignment - (currentOffset & alignmentMask)) & alignmentMask
            let totalSize = size + padding
            newOffset = currentOffset + totalSize
            
            precondition(newOffset <= byteCount)
        } while !offset.compareExchange(expected: currentOffset, desired: newOffset, ordering: .relaxed).exchanged
        
        return ptr.advanced(by: currentOffset + padding)
    }
    
    func reset() {
        offset.store(0, ordering: .relaxed)
    }

    func deallocate(_ ptr: UnsafeRawPointer) {
        // do nothing
    }
}

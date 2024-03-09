import Atomics

final class MonotonicAllocator: @unchecked Sendable {
    let byteCount: Int
    let alignment: Int
    let offset = ManagedAtomic(0)
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
    
    func allocate<T>(_ type: T.Type = T.self) -> UnsafeMutablePointer<T> {
        let layout = MemoryLayout<T>.self
        
        return allocate(size: layout.size, alignment: layout.alignment).bindMemory(to: T.self, capacity: 1)
    }
}

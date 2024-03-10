import Foundation

struct SystemAllocator: Allocator {
    func allocate(byteCount: Int, alignment: Int) -> UnsafeMutableRawPointer {
        .allocate(byteCount: byteCount, alignment: alignment)
    }
    
    func deallocate(_ ptr: UnsafeRawPointer) {
        ptr.deallocate()
    }
}

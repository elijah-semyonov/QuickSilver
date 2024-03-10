import Foundation

struct SystemAllocator: Allocator {
    func allocate(size: Int, alignment: Int) -> UnsafeMutableRawPointer {
        .allocate(byteCount: size, alignment: alignment)
    }
    
    func deallocate(_ ptr: UnsafeRawPointer) {
        ptr.deallocate()
    }
}

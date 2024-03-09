import Foundation

public protocol Allocator {
    func allocate(size: Int, alignment: Int) -> UnsafeMutableRawPointer
    func deallocate(_ ptr: UnsafeRawPointer)
}

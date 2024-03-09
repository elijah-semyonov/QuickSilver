import Foundation

public protocol Allocator {
    func allocate(size: Int, alignment: Int) -> UnsafeMutableRawPointer
    func deallocate(_ ptr: UnsafeRawPointer)
}

extension Allocator {
    func allocate<T>(_ type: T.Type = T.self) -> UnsafeMutablePointer<T> {
        let layout = MemoryLayout<T>.self
        
        return allocate(size: layout.size, alignment: layout.alignment).bindMemory(to: T.self, capacity: 1)
    }
    
    func store<T>(_ value: T) -> UnsafeMutablePointer<T> {
        let ptr = allocate(T.self)
        ptr.initialize(to: value)
        return ptr
    }
}

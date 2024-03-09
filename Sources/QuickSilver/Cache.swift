import Foundation

public actor Cache<Key: Hashable, Value> {
    enum Record {
        case loading(Task<Value, Never>)
        case loaded(Value)
    }
    
    private var records: [Key: Record] = [:]
    
    public func get(key: Key, orLoad load: @escaping () async -> Value) async -> Value {
        if let record = records[key] {
            switch record {
            case .loading(let task):
                return await task.value
            case .loaded(let value):
                return value
            }
        } else {
            let task = Task {
                return await load()
            }
            
            records[key] = .loading(task)
            
            let value = await task.value
            
            records[key] = .loaded(value)
            
            return value
        }
    }
}

struct BytesCount {
    let value: Int
    
    init(_ value: Int) {
        precondition(value >= 0)
        
        self.value = value
    }
    
    static func mebibytes(_ value: Int) -> Self {
        return Self(value * 1_048_576)
    }
}

import Foundation

public struct ClearColor {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double
    
    public init(red: Double, green: Double, blue: Double, alpha: Double) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }
}

extension LoadAction<ClearColor> {
    public static func clear(red: Double, green: Double, blue: Double, alpha: Double) -> Self {
        .clear(ClearValue(red: red, green: green, blue: blue, alpha: alpha))
    }
}

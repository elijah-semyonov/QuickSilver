import Foundation

class FrameResourceUsageTrackers {
    private var textures: [Texture: TextureUsageTracker] = [:]
    
    subscript(_ texture: Texture) -> TextureUsageTracker {
        get {
            guard let tracker = textures[texture] else {
                fatalError("No tracker registered for \(texture) in current frame")
            }
            
            return tracker
        }
    }
    
    func register(_ tracker: TextureUsageTracker) -> Texture {
        let texture = Texture(id: textures.count)
        
        textures[texture] = tracker
        
        return texture
    }
}

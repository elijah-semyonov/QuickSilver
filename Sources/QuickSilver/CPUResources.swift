import Foundation
import Metal

#if canImport(UIKit)
import UIKit
#endif

public struct CPUResources: ~Copyable {
    init() {
    }
    
    public func accessTexture<T>(_ texture: Texture, _ closure: (MTLTexture) -> T) -> T {
        closure(texture.mtlTexture)
    }
    
    public func textureData(_ texture: Texture, mipmapLevel: Int = 0, slice: Int = 0) -> Data {
        accessTexture(texture) { texture in
            let bytesPerRow = texture.width * texture.pixelFormat.bytesPerPixel
            let bytesPerImage = bytesPerRow * texture.height
            let ptr = UnsafeMutableRawPointer.allocate(byteCount: bytesPerImage, alignment: 1)
            
            let data = Data(
                bytesNoCopy: ptr,
                count: bytesPerImage,
                deallocator: Data.Deallocator.custom { ptr, count in
                    ptr.deallocate()
                }
            )
            
            let region = MTLRegion(
                origin: MTLOrigin(x: 0, y: 0, z: 0),
                size: MTLSize(width: texture.width, height: texture.height, depth: texture.depth)
            )
            
            texture.getBytes(ptr, bytesPerRow: bytesPerRow, bytesPerImage: bytesPerImage, from: region, mipmapLevel: mipmapLevel, slice: slice)
            
            return data
        }
    }
    
    #if canImport(UIKit)
    public func image(from texture: Texture, mipmapLevel: Int = 0, slice: Int = 0) -> UIImage? {
        let mtlTexture = texture.mtlTexture
        
        let data = textureData(texture, mipmapLevel: mipmapLevel, slice: slice)
        let width = mtlTexture.width
        let height = mtlTexture.height
    
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            fatalError("Can't create CGDataProvider")
        }
        let bitsPerComponent = 8
        let bytesPerPixel = mtlTexture.pixelFormat.bytesPerPixel
        let bitsPerPixel = bytesPerPixel * bitsPerComponent
        let bytesPerRow = bytesPerPixel * width
        let colorSpace = CGColorSpaceCreateDeviceRGB()

        if let cgImage = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue),
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        ) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    #endif
}

//
//  ImageSurface.swift
//  Silica
//
//  Created by Alsey Coleman Miller on 6/3/17.
//
//

import Foundation

@_exported import CCairo

extension Surface {
    
    /// Image surfaces provide the ability to render to memory buffers either allocated by Cairo or by the calling code.
    /// The supported image formats are those defined in `ImageFormat`.
    public final class Image: Surface {
        
        // MARK: - Initialization
        
        /// Creates an image surface of the specified format and dimensions. 
        ///
        /// Initially the surface contents are all 0. 
        /// Specifically, within each pixel, each color or alpha channel belonging to format will be 0.
        /// The contents of bits within a pixel, but not belonging to the given format are undefined.
        public init(format: ImageFormat, width: Int, height: Int) throws {
            
            let internalPointer = cairo_image_surface_create(cairo_format_t(format), Int32(width), Int32(height))!
            
            try super.init(internalPointer)
        }
        
        /// Creates an image surface for the provided pixel data.
        public init(mutableBytes bytes: UnsafeMutablePointer<UInt8>, format: ImageFormat, width: Int, height: Int, stride: Int) throws {
            
            assert(format.stride(for: width) == stride, "Invalid stride")
            
            let internalPointer = cairo_image_surface_create_for_data(bytes, cairo_format_t(format), Int32(width), Int32(height), Int32(stride))!
            
            try super.init(internalPointer)
        }
        
        /// Creates an image surface for the provided pixel data, copying the buffer.
        public convenience init(data: Data, format: ImageFormat, width: Int, height: Int, stride: Int) throws {
            
            var data = data
            
            // a bit unsafe, but cant use self.init inside closure.
            let bytes: UnsafeMutablePointer<UInt8> = data.withUnsafeMutableBytes { $0 }
            
            try self.init(mutableBytes: bytes, format: format, width: width, height: height, stride: stride)
        }
        
        /// For internal use with extensions (e.g. `init(pngData:)`)
        internal override init(_ internalPointer: OpaquePointer) throws {
            
            try super.init(internalPointer)
        }
                
        // MARK: - Class Methods
        
        public override class func isCompatible(with surfaceType: SurfaceType) -> Bool {
            
            switch surfaceType {
                
            case .image: return true
            default: return false
            }
        }
        
        // MARK: - Accessors
        
        /// Get the format of the surface.
        public var format: ImageFormat? {
            
            return ImageFormat(cairo_image_surface_get_format(internalPointer))
        }
        
        /// Get the width of the image surface in pixels.
        public var width: Int {
            
            return Int(cairo_image_surface_get_width(internalPointer))
        }
        
        /// Get the height of the image surface in pixels.
        public var height: Int {
            
            return Int(cairo_image_surface_get_height(internalPointer))
        }
        
        /// Get the stride of the image surface in bytes
        public var stride: Int {
            
            return Int(cairo_image_surface_get_stride(internalPointer))
        }
        
        /// Get a pointer to the data of the image surface, for direct inspection or modification.
        public func withUnsafeMutableBytes<Result>(_ body: (UnsafeMutablePointer<UInt8>) throws -> Result) rethrows -> Result? {
            
            guard let bytes = cairo_image_surface_get_data(internalPointer)
                else { return nil }
            
            return try body(bytes)
        }
        
        /// Get the immutable data of the image surface.
        public lazy var data: Data? = {
            
            let internalPointer = self.internalPointer
            
            let length = self.stride * self.height
            
            return self.withUnsafeMutableBytes { (bytes) in
                
                let pointer = UnsafeMutableRawPointer(bytes)
                
                // retain surface pointer so the data can still exist even after Swift object deinit
                cairo_surface_reference(internalPointer)
                
                let deallocator = Data.Deallocator.custom({ (_, _) in cairo_surface_destroy(internalPointer) })
                
                return Data(bytesNoCopy: pointer, count: length, deallocator: deallocator)
            }
        }()
    }
}

extension Surface.Image {

    private static let pngBytes: [UInt8] = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]
    private static let jpegBytes: [UInt8] = [0xFF, 0xD8]

    public convenience init(contentsOfFile path: String) throws {
        guard let fileHandle = FileHandle(forReadingAtPath: path) else {
            throw CairoError(rawValue: CAIRO_STATUS_READ_ERROR.rawValue)!
        }
        let data = fileHandle.readData(ofLength: 8)
        let compare = { (magicBytes: [UInt8]) -> Bool in
            for (byte, magicByte) in zip(data.map { $0 }, magicBytes) {
                guard byte == magicByte else { return false }
            }
            return true
        }
        if compare(Surface.Image.pngBytes) {
            try self.init(contentsOfPngFile: path)
        } else if compare(Surface.Image.jpegBytes) {
            try self.init(contentsOfJpegFile: path)
        } else {
            throw CairoError(rawValue: CAIRO_STATUS_READ_ERROR.rawValue)!
        }
    }
}

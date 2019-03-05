//
//  SurfacePNG.swift
//  Cairo
//
//  Created by Alsey Coleman Miller on 6/5/17.
//
//

import struct Foundation.Data
import CCairo

extension Surface {
    
    /// Writes the surface's contents to a PNG file.
    public func writePNG(atPath path: String) {
        
        cairo_surface_write_to_png(internalPointer, path)
    }
    
    public func writePNG() throws -> Data {
        
        let dataProvider = DataProvider()
        
        let unmanaged = Unmanaged.passUnretained(dataProvider)
        
        let pointer = unmanaged.toOpaque()
        
        if let error = cairo_surface_write_to_png_stream(internalPointer, pngWrite, pointer).toError() {
            
            throw error
        }
        
        return dataProvider.data
    }
}

extension Surface.Image {
    
    /// Creates a new image surface from PNG data read incrementally via the read function.
    @inline(__always)
    fileprivate convenience init(png readFunction: @escaping cairo_read_func_t, closure: UnsafeMutableRawPointer) throws {
        
        let internalPointer = cairo_image_surface_create_from_png_stream(readFunction, closure)!
        
        try self.init(internalPointer)
    }
    
    public convenience init(png data: Data) throws {
        
        let dataProvider = DataProvider(data: data)
        
        let unmanaged = Unmanaged.passUnretained(dataProvider)
        
        let pointer = unmanaged.toOpaque()
        
        try self.init(png: pngRead, closure: pointer)
    }
}

// MARK: - Private Functions

@_silgen_name("_cairo_swift_png_read_data")
private func pngRead(_ closure: UnsafeMutableRawPointer?, _ data: UnsafeMutablePointer<UInt8>?, _ length: UInt32) -> cairo_status_t {
    
    let unmanaged = Unmanaged<Surface.DataProvider>.fromOpaque(closure!)
    
    let dataProvider = unmanaged.takeUnretainedValue()
    
    return dataProvider.copyBytes(to: data!, length: Int(length))
}

@_silgen_name("_cairo_swift_png_write_data")
private func pngWrite(_ closure: UnsafeMutableRawPointer?, _ data: UnsafePointer<UInt8>?, _ length: UInt32) -> cairo_status_t {
    
    let unmanaged = Unmanaged<Surface.DataProvider>.fromOpaque(closure!)
    
    let dataProvider = unmanaged.takeUnretainedValue()
    
    return dataProvider.copyBytes(from: data!, length: Int(length))
}

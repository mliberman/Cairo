
import struct Foundation.Data

import CCairo
import CCairoJPEG

public extension Surface {

    public func writeJPEG(atPath path: String, withQuality quality: Int32) {
        cairo_image_surface_write_to_jpeg(internalPointer, path, quality)
    }

    public func writeJPEG(withQuality quality: Int32) throws -> Data {

        let dataProvider = DataProvider()

        let unmanaged = Unmanaged.passUnretained(dataProvider)

        let pointer = unmanaged.toOpaque()

        if let error = cairo_image_surface_write_to_jpeg_stream(internalPointer, jpegWrite, pointer, quality).toError() {

            throw error
        }

        return dataProvider.data
    }
}

public extension Surface.Image {

    /// Creates a new image surface from JPEG data read incrementally via the read function.
    @inline(__always)
    fileprivate convenience init(jpeg readFunction: @escaping cairo_read_func_t, closure: UnsafeMutableRawPointer) throws {

        let internalPointer = cairo_image_surface_create_from_jpeg_stream(readFunction, closure)!

        try self.init(internalPointer)
    }

    convenience init(jpeg data: Data) throws {

        let dataProvider = DataProvider(data: data)

        let unmanaged = Unmanaged.passUnretained(dataProvider)

        let pointer = unmanaged.toOpaque()

        try self.init(jpeg: jpegRead, closure: pointer)
    }
}

// MARK: - Private Functions

@_silgen_name("_cairo_swift_jpeg_read_data")
private func jpegRead(_ closure: UnsafeMutableRawPointer?, _ data: UnsafeMutablePointer<UInt8>?, _ length: UInt32) -> cairo_status_t {

    let unmanaged = Unmanaged<Surface.DataProvider>.fromOpaque(closure!)

    let dataProvider = unmanaged.takeUnretainedValue()

    return dataProvider.copyBytes(to: data!, length: Int(length))
}

@_silgen_name("_cairo_swift_jpeg_write_data")
private func jpegWrite(_ closure: UnsafeMutableRawPointer?, _ data: UnsafePointer<UInt8>?, _ length: UInt32) -> cairo_status_t {

    let unmanaged = Unmanaged<Surface.DataProvider>.fromOpaque(closure!)

    let dataProvider = unmanaged.takeUnretainedValue()

    return dataProvider.copyBytes(from: data!, length: Int(length))
}

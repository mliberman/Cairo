
import struct Foundation.Data

@_exported import CCairo
@_exported import CCairoJPEG

extension Surface {

    public func writeJPEG(atPath path: String, withQuality quality: Int32) {
        cairo_image_surface_write_to_jpeg(internalPointer, path, quality)
    }

    public func writeJPEG(withQuality quality: Int32) throws -> Data {

        let dataProvider = JPEGDataProvider()

        let unmanaged = Unmanaged.passUnretained(dataProvider)

        let pointer = unmanaged.toOpaque()

        if let error = Status(cairo_image_surface_write_to_jpeg_stream(internalPointer, jpegWrite, pointer, quality)).toError() {

            throw error
        }

        return dataProvider.data
    }
}

extension Surface.Image {

    /// Creates a new image surface from JPEG data read incrementally via the read function.
    @inline(__always)
    fileprivate convenience init(jpeg readFunction: @escaping cairo_read_func_t, closure: UnsafeMutableRawPointer) throws {

        let internalPointer = cairo_image_surface_create_from_jpeg_stream(readFunction, closure)!

        try self.init(internalPointer)
    }

    public convenience init(jpeg data: Data) throws {

        let dataProvider = JPEGDataProvider(data: data)

        let unmanaged = Unmanaged.passUnretained(dataProvider)

        let pointer = unmanaged.toOpaque()

        try self.init(jpeg: jpegRead, closure: pointer)
    }

    public static func jpeg(fromFile path: String) throws -> Surface.Image {
        return try Surface.Image(cairo_image_surface_create_from_jpeg(path.cString(using: .utf8))!)
    }
}

fileprivate extension Surface {

    final class JPEGDataProvider {

        private(set) var data: Data
        private(set) var readPosition: Int = 0

        init(data: Data = Data()) {
            self.data = data
        }

        @inline(__always)
        func copyBytes(to pointer: UnsafeMutablePointer<UInt8>, length: Int) -> cairo_status_t {

            var size = length

            if (readPosition + size) > data.count {
                size = data.count - readPosition;
            }

            if size == 0 {
                return CAIRO_STATUS_READ_ERROR
            }

            let byteRange: Range<Data.Index> = readPosition ..< readPosition + size

            let _ = data.copyBytes(to: pointer, from: byteRange)

            readPosition += size

            return CAIRO_STATUS_SUCCESS
        }

        @inline(__always)
        func copyBytes(from pointer: UnsafePointer<UInt8>, length: Int) -> cairo_status_t {

            data.append(pointer, count: length)

            return CAIRO_STATUS_SUCCESS
        }
    }
}

// MARK: - Private Functions

@_silgen_name("_cairo_swift_jpeg_read_data")
private func jpegRead(_ closure: UnsafeMutableRawPointer?, _ data: UnsafeMutablePointer<UInt8>?, _ length: UInt32) -> cairo_status_t {

    let unmanaged = Unmanaged<Surface.JPEGDataProvider>.fromOpaque(closure!)

    let dataProvider = unmanaged.takeUnretainedValue()

    return dataProvider.copyBytes(to: data!, length: Int(length))
}

@_silgen_name("_cairo_swift_jpeg_write_data")
private func jpegWrite(_ closure: UnsafeMutableRawPointer?, _ data: UnsafePointer<UInt8>?, _ length: UInt32) -> cairo_status_t {

    let unmanaged = Unmanaged<Surface.JPEGDataProvider>.fromOpaque(closure!)

    let dataProvider = unmanaged.takeUnretainedValue()

    return dataProvider.copyBytes(from: data!, length: Int(length))
}

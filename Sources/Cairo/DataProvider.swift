//
//  DataProvider.swift
//  Cairo
//
//  Created by Max Liberman on 3/5/19.
//

import struct Foundation.Data
import CCairo

extension Surface {

    internal final class DataProvider {

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

//
//  Buffer.swift
//  Onewheel-SwiftUI (iOS)
//
//  Created by Adin Ackerman on 12/2/22.
//

import Foundation

struct Buffer {
    static func getUInt16(buf: [UInt8], index: inout Int) -> UInt16 {
        let res = UInt16(buf[index    ]) << 8  |
                  UInt16(buf[index + 1])
        index += 2
        return res
    }
    
    static func getInt16(buf: [UInt8], index: inout Int) -> Int16 {
        let res = Int16(truncatingIfNeeded:
            UInt16(buf[index    ]) << 8  |
            UInt16(buf[index + 1])
        )
        index += 2
        return res
    }
    
    static func getInt32(buf: [UInt8], index: inout Int) -> Int32 {
        let res = Int32(truncatingIfNeeded:
            UInt32(buf[index    ]) << 24 |
            UInt32(buf[index + 1]) << 16 |
            UInt32(buf[index + 2]) << 8  |
            UInt32(buf[index + 3])
        )
        index += 4
        return res
    }
    
    static func getFloat16(buf: [UInt8], scale: Float16, index: inout Int) -> Float16 {
        return Float16(getInt16(buf: buf, index: &index)) / scale
    }
    
    static func getFloat32(buf: [UInt8], scale: Float32, index: inout Int) -> Float32 {
        return Float32(getInt32(buf: buf, index: &index)) / scale
    }
}

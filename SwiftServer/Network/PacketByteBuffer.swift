//
//  PacketByteBuffer.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public typealias Byte = UInt8

public class PacketByteBuffer {
    private var data: Data
    private var pointer: Int = 0
    
    /// 用于读取的构造器
    /// - Parameter data: 要读取的数据
    public init(data: Data) {
        self.data = data
    }
    
    /// 用于写入的构造器
    public init() {
        self.data = Data()
    }
    
    public func readByte() -> Byte {
        pointer += 1
        return data[pointer - 1]
    }
    
    @discardableResult
    public func writeByte(_ byte: Byte) -> PacketByteBuffer {
        data.append(byte)
        return self
    }
    
    /// 读取一些字节
    /// - Parameter count: 读取的字节数
    /// - Returns: 读取到的字节
    public func readBytes(_ count: Int) -> [Byte] {
        var bytes: [Byte] = []
        for _ in 0..<count { bytes.append(readByte()) }
        return bytes
    }
    
    /// 读取一些字节，并转换成 Data 类型
    /// - Parameter count: 读取的字节数
    /// - Returns: 读取到的字节
    public func readBytesAsData(_ count: Int) -> Data { Data(readBytes(count)) }
    
    /// 写入一些字节
    /// - Parameter bytes: 要写入的字节
    @discardableResult
    public func writeBytes(_ bytes: [Byte]) -> PacketByteBuffer {
        let _ = bytes.map(writeByte(_:))
        return self
    }
    
    /// 写入一段 Data
    /// - Parameter data: 要写入的 Data
    @discardableResult
    public func writeBytes(data: Data) -> PacketByteBuffer {
        let _ = data.map(writeByte(_:))
        return self
    }
    
    public func readInt() -> Int {
        return readBytesAsData(4).withUnsafeBytes { Int(UInt32(bigEndian: $0.load(as: UInt32.self))) }
    }
    
    @discardableResult
    public func writeInt(_ value: Int) -> PacketByteBuffer {
        var value = UInt32(value).bigEndian
        let bytes = withUnsafeBytes(of: &value) { Data($0) }
        return writeBytes(data: bytes)
    }
    
    public func readLong() -> Int64 {
        return readBytesAsData(8).withUnsafeBytes { Int64(UInt64(bigEndian: $0.load(as: UInt64.self))) }
    }
    
    @discardableResult
    public func writeLong(_ value: Int64) -> PacketByteBuffer {
        var value = UInt64(value).bigEndian
        let bytes = withUnsafeBytes(of: &value) { Data($0) }
        return writeBytes(data: bytes)
    }
    
    public func readULong() -> UInt64 {
        return readBytesAsData(8).withUnsafeBytes { UInt64(bigEndian: $0.load(as: UInt64.self)) }
    }
    
    @discardableResult
    public func writeULong(_ value: UInt64) -> PacketByteBuffer {
        var value = value.bigEndian
        let bytes = withUnsafeBytes(of: &value) { Data($0) }
        return writeBytes(data: bytes)
    }
    
    public func readShort() -> Int16 {
        let bytes = readBytes(2)
        let value = UInt16(bytes[0]) << 8 | UInt16(bytes[1])
        return Int16(bitPattern: value)
    }
    
    @discardableResult
    public func writeShort(_ value: Int16) -> PacketByteBuffer {
        let v = UInt16(bitPattern: value).bigEndian
        return withUnsafeBytes(of: v) { buffer in
            writeBytes(Array(buffer))
        }
    }
    
    public func readUShort() -> UInt16 {
        let bytes = readBytes(2)
        return UInt16(bytes[0]) << 8 | UInt16(bytes[1])
    }
    
    @discardableResult
    public func writeUShort(_ value: UInt16) -> PacketByteBuffer {
        let v = value.bigEndian
        return withUnsafeBytes(of: v) { buffer in
            writeBytes(Array(buffer))
        }
    }
    
    public func readUUID() -> UUID {
        var highBE = readULong().bigEndian
        var lowBE = readULong().bigEndian
        
        let data = withUnsafeBytes(of: &highBE) { Data($0) } + withUnsafeBytes(of: &lowBE) { Data($0) }
        return UUID(uuid: (
            data[0], data[1], data[2], data[3],
            data[4], data[5], data[6], data[7],
            data[8], data[9], data[10], data[11],
            data[12], data[13], data[14], data[15]
        ))
    }
    
    @discardableResult
    public func writeUUID(_ uuid: UUID) -> PacketByteBuffer {
        let bytes = uuid.uuid
        let high = (UInt64(bytes.0) << 56) | (UInt64(bytes.1) << 48) | (UInt64(bytes.2) << 40) | (UInt64(bytes.3) << 32) |
        (UInt64(bytes.4) << 24) | (UInt64(bytes.5) << 16) | (UInt64(bytes.6) << 8)  | UInt64(bytes.7)
        let low  = (UInt64(bytes.8) << 56) | (UInt64(bytes.9) << 48) | (UInt64(bytes.10) << 40) | (UInt64(bytes.11) << 32) |
        (UInt64(bytes.12) << 24) | (UInt64(bytes.13) << 16) | (UInt64(bytes.14) << 8)  | UInt64(bytes.15)
        writeULong(high)
        return writeULong(low)
    }
    
    /// 按 VarInt 格式读取一个 Int
    /// - Returns: 读取到的 VarInt
    public func readVarInt() -> Int {
        var value = 0
        var position = 0
        while true {
            let byte = readByte()
            value |= Int(byte & 0x7F) << (7 * position)
            if (byte & 0x80) == 0 {
                break
            }
            position += 1
            if position > 4 {
                fatalError("VarInt too big")
            }
        }
        return value
    }
    
    /// 按 VarInt 格式写入一个 Int
    /// - Parameter value: 要写入的 Int
    @discardableResult
    public func writeVarInt(_ value: Int) -> PacketByteBuffer {
        var value = value
        while (value & ~0x7F) != 0 {
            writeByte(UInt8((value & 0x7F) | 0x80));
            value >>= 7;
        }
        return writeByte(UInt8(value))
    }
    
    func readString(maxLength: Int = 32767) -> String {
        let byteLength = readVarInt()
        // 检查长度
        guard byteLength >= 0 else {
            fatalError("The received encoded string buffer length is less than zero! Weird string!")
        }
        guard byteLength <= maxLength * 3 else {
            fatalError("The received encoded string buffer length is longer than maximum allowed (\(byteLength) > \(maxLength * 3)")
        }
        // 读取字符串
        let bytes = readBytes(byteLength)
        guard let str = String(data: Data(bytes), encoding: .utf8) else {
            fatalError("Failed to decode string")
        }
        guard str.count <= maxLength else {
            fatalError("The received string length is longer than maximum allowed (\(str.count) > \(maxLength))")
        }
        return str
    }
    
    @discardableResult
    func writeString(_ string: String, maxLength: Int = 32767) -> PacketByteBuffer {
        guard string.count <= maxLength else {
            fatalError("String too big (was \(string.count) characters, max \(maxLength))")
        }
        guard let data = string.data(using: .utf8) else {
            fatalError("Failed to encode string")
        }
        let byteLength = data.count
        guard byteLength <= maxLength * 3 else {
            fatalError("String too big (was \(byteLength) bytes encoded, max \(maxLength))")
        }
        writeVarInt(byteLength)
        return writeBytes(data: data)
    }
    
    public func toData() -> Data { data }
    public var avaliableBytes: Int { data.count - pointer }
}

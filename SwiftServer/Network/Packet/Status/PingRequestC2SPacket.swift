//
//  PingRequestC2SPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public class PingRequestC2SPacket: Packet {
    public let id: Int = 0x01
    public let resourceLocation: String = "ping_request"
    public let timestamp: Int64
    
    public init(timestamp: Int64) {
        self.timestamp = timestamp
    }
    
    public func encode(to buf: PacketByteBuffer) {
        buf.writeLong(timestamp)
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        self.init(timestamp: buf.readLong())
    }
}

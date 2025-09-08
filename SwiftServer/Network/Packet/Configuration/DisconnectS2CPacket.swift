//
//  DisconnectS2CPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class DisconnectS2CPacket: Packet {
    public let id: Int = 0x02
    public let identifier: Identifier = .init("disconnect")
    public let reason: String
    
    public init(reason: String) {
        self.reason = reason
    }
    
    public func encode(to buf: PacketByteBuffer) {
        buf
            .writeBytes([0x08])
            .writeUShort(UInt16(reason.count))
            .writeBytes(data: reason.data(using: .utf8) ?? Data())
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        self.init(reason: buf.readString())
    }
}

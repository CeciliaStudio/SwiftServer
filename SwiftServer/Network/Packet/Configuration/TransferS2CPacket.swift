//
//  TransferS2CPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class TransferS2CPacket: Packet {
    public let id: Int = 0x0B
    public let identifier: Identifier = .init("transfer")
    public let host: String
    public let port: Int
    
    public init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    public func encode(to buf: PacketByteBuffer) {
        buf
            .writeString(host)
            .writeVarInt(port)
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        self.init(host: buf.readString(), port: buf.readVarInt())
    }
}

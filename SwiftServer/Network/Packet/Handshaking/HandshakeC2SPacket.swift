//
//  HandshakeC2SPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public class HandshakeC2SPacket: Packet {
    public let id: Int = 0x00
    public let identifier: Identifier = .init("intention")
    
    public let protocolVersion: Int
    public let address: String
    public let port: UInt16
    public let nextState: Int
    
    init(protocolVersion: Int, address: String, port: UInt16, nextState: Int) {
        self.protocolVersion = protocolVersion
        self.address = address
        self.port = port
        self.nextState = nextState
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        self.init(
            protocolVersion: buf.readVarInt(),
            address: buf.readString(),
            port: buf.readUShort(),
            nextState: buf.readVarInt()
        )
    }
    
    public func encode(to buf: PacketByteBuffer) {
        buf
            .writeVarInt(protocolVersion)
            .writeString(address)
            .writeUShort(port)
            .writeVarInt(nextState)
    }
}

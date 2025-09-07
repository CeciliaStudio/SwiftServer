//
//  LoginStartC2SPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public class LoginStartC2SPacket: Packet {
    public let id: Int = 0x00
    public let identifier: Identifier = .init("hello")
    public let name: String
    public let uuid: UUID
    
    public init(name: String, uuid: UUID) {
        self.name = name
        self.uuid = uuid
    }
    
    
    public func encode(to buf: PacketByteBuffer) {
        buf
            .writeString(name)
            .writeUUID(uuid)
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        self.init(name: buf.readString(), uuid: buf.readUUID())
    }
}

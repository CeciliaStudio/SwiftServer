//
//  LoginSuccessS2CPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public class LoginSuccessS2CPacket: Packet {
    public let id: Int = 0x02
    public let identifier: Identifier = .init("game_profile")
    public let uuid: UUID
    public let name: String
    
    init(uuid: UUID, name: String) {
        self.uuid = uuid
        self.name = name
    }
    
    public func encode(to buf: PacketByteBuffer) {
        buf
            .writeUUID(uuid)
            .writeString(name)
            .writeVarInt(0)
            .writeByte(0x00)
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        self.init(uuid: buf.readUUID(), name: buf.readString())
    }
}

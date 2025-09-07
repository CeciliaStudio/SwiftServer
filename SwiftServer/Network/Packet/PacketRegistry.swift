//
//  PacketRegistry.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public class PacketRegistry {
    public static let handshaking = PacketRegistry()
    public static let status = PacketRegistry()
    public static let login = PacketRegistry()
    public static let play = PacketRegistry()
    
    private var packetMap: [Int : any Packet.Type] = [:]
    
    public func register(id: Int, type: any Packet.Type) {
        packetMap[id] = type
    }
    
    public func getType(id: Int) -> (any Packet.Type)? {
        return packetMap[id]
    }
    
    public static func registerPackets() {
        handshaking.register(id: 0x00, type: HandshakeC2SPacket.self)
        
        status.register(id: 0x00, type: StatusRequestC2SPacket.self)
        status.register(id: 0x01, type: PingRequestC2SPacket.self)
        
        login.register(id: 0x00, type: LoginStartC2SPacket.self)
    }
}

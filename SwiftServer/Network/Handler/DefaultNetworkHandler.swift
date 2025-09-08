//
//  DefaultNetworkHandler.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation
import CryptoKit

public class DefaultNetworkHandler: NetworkHandler {
    public var connection: Connection!
    
    public func receivePacket(packet: any Packet) {
        switch packet {
        case let packet as HandshakeC2SPacket: onHandshake(packet: packet)
            
        case _ as StatusRequestC2SPacket: onStatusRequest()
        case let packet as PingRequestC2SPacket: onPing(packet: packet)
            
        case let packet as LoginStartC2SPacket: onLoginStart(packet: packet)
        case _ as LoginAcknowlegedC2SPacket: onLoginAcknowleged()
            
        case let packet as ClientInformationC2SPacket: onClientInformation(packet: packet)
        case _ as FinishConfigurationPacket: connection.switchState(.play)
        default: break
        }
    }
    
    private func onHandshake(packet: HandshakeC2SPacket) {
        connection.protocolVersion = packet.protocolVersion
        switch packet.nextState {
        case 1: connection.switchState(.status)
        case 2: connection.switchState(.login)
        default: break
        }
    }
    
    private func onStatusRequest() {
        let protocolVersion = connection.protocolVersion
        Task {
            try await self.sendPacket(
                StatusResponseS2CPacket(
                    versionName: ServerMetadata.shared.version,
                    protocolVersion: ServerMetadata.shared.protocolVersion,
                    motd: "§6SwiftServer Connector§7\n您的协议版本为：§\(protocolVersion >= ServerMetadata.shared.protocolVersion ? "a" : "c")\(protocolVersion)",
                    players: []
                )
            )
        }
    }
    
    private func onPing(packet: PingRequestC2SPacket) {
        Task {
            try await self.sendPacket(packet)
        }
    }
    
    private func onLoginStart(packet: LoginStartC2SPacket) {
        debug("\(packet.name) 正在登录")
        let hash = Insecure.MD5.hash(data: Array("OfflinePlayer:\(packet.name)".utf8))
        var hashBytes = Array(hash)
        hashBytes[6] = (hashBytes[6] & 0x0F) | 0x30
        hashBytes[8] = (hashBytes[8] & 0x3F) | 0x80
        let uuid = UUID(uuid: (
            hashBytes[0], hashBytes[1], hashBytes[2], hashBytes[3],
            hashBytes[4], hashBytes[5], hashBytes[6], hashBytes[7],
            hashBytes[8], hashBytes[9], hashBytes[10], hashBytes[11],
            hashBytes[12], hashBytes[13], hashBytes[14], hashBytes[15]
        ))
        Task {
            try await self.sendPacket(LoginSuccessS2CPacket(uuid: uuid, name: packet.name))
        }
    }
    
    private func onLoginAcknowleged() {
        connection.switchState(.configuration)
        // 发送服务端配置
        Task {
            try await sendPacket(BrandCustomPayloadS2CPacket(brand: "swift"))
            try await sendPacket(ServerLinksS2CPacket(links: [
                .init(label: .bugReport, url: "https://github.com/CeciliaStudio/SwiftServer/issues"),
                .init(label: .status, url: "https://github.com/CeciliaStudio/SwiftServer/pulse"),
                .init(label: .community, url: "https://github.com/CeciliaStudio/SwiftServer/graphs/community")
            ]))
//            try await sendPacket(FinishConfigurationPacket())
        }
    }
    
    private func onClientInformation(packet: ClientInformationC2SPacket) {
        let text = switch packet.locale.identifier {
        case "zh_CN": "游玩功能暂未实现"
        default: "Playing is not implemented on this server"
        }
        Task {
            try await sendPacket(DisconnectS2CPacket(reason: text))
        }
    }
}

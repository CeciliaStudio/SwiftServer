//
//  StatusResponseS2CPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation
import SwiftyJSON

public class StatusResponseS2CPacket: Packet {
    public let id: Int = 0
    public let identifier: Identifier = .init("status_response")
    public let versionName: String
    public let protocolVersion: Int
    public let motd: String
    public let players: [PlayerProfile]
    
    public func encode(to buf: PacketByteBuffer) {
        let dict = [
            "version": [
                "name": versionName,
                "protocol": protocolVersion
            ],
            "players": [
                "max": 114514,
                "online": players.count,
                "sample": players
            ],
            "description": [
                "text": motd
            ]
        ]
        guard let data = try? JSONSerialization.data(withJSONObject: dict),
              let jsonString = String(data: data, encoding: .utf8) else {
            err("无法将字典转换为 JSON")
            return
        }
        buf.writeString(jsonString)
    }
    
    public init(versionName: String, protocolVersion: Int, motd: String, players: [PlayerProfile]) {
        self.versionName = versionName
        self.protocolVersion = protocolVersion
        self.motd = motd
        self.players = players
    }
    
    public required init(from buf: PacketByteBuffer) {
        let jsonString = buf.readString()
        guard let json = try? JSON(data: jsonString.data(using: .utf8)!) else {
            fatalError("Failed to parse JSON: \(jsonString)")
        }
        self.versionName = json["version"]["name"].stringValue
        self.protocolVersion = json["version"]["protocol"].intValue
        self.motd = json["description"]["text"].stringValue
        self.players = json["players"]["sample"].arrayValue.map { json in
            PlayerProfile(id: json["id"].stringValue, name: json["name"].stringValue)
        }
    }
}

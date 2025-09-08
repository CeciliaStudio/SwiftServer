//
//  ServerLinksS2CPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class ServerLinksS2CPacket: Packet {
    public let id: Int = 0x10
    public let identifier: Identifier = .init("server_links")
    public let links: [Link]
    
    public init(links: [Link]) {
        self.links = links
    }
    
    public func encode(to buf: PacketByteBuffer) {
        buf.writeVarInt(links.count)
        for link in links {
            buf
                .writeByte(0x01)
                .writeVarInt(link.label.rawValue)
                .writeString(link.url)
        }
    }
    
    public required init(from buf: PacketByteBuffer) {
        let length = buf.readVarInt()
        var links: [Link] = []
        for _ in 0..<length {
            let _ = buf.readByte()
            let link = Link(label: .init(rawValue: buf.readVarInt()) ?? .bugReport, url: buf.readString())
            links.append(link)
        }
        self.links = links
    }
    
    public enum Label: Int {
        case bugReport = 0
        case communityGuidelines = 1
        case support = 2
        case status = 3
        case feedback = 4
        case community = 5
        case website = 6
        case forums = 7
        case news = 8
        case announcements = 9
    }
    
    public struct Link {
        public let label: Label
        public let url: String
    }
}

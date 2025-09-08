//
//  ClientInformationC2SPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class ClientInformationC2SPacket: Packet {
    public let id: Int = 0x00
    public let identifier: Identifier = .init("client_information")
    public let locale: Locale
    public let renderDistance: Int
    public let chatMode: ChatMode
    public let chatColorsEnabled: Bool
    public let skinParts: Byte
    public let mainHand: HandType
    public let filtersText: Bool
    public let allowsServerListing: Bool
    
    init(locale: Locale, renderDistance: Int, chatMode: ChatMode, chatColorsEnabled: Bool, skinParts: Byte, mainHand: HandType, filtersText: Bool, allowsServerListing: Bool) {
        self.locale = locale
        self.renderDistance = renderDistance
        self.chatMode = chatMode
        self.chatColorsEnabled = chatColorsEnabled
        self.skinParts = skinParts
        self.mainHand = mainHand
        self.filtersText = filtersText
        self.allowsServerListing = allowsServerListing
    }
    
    public func encode(to buf: PacketByteBuffer, protocolVersion: Int) {
        buf
            .writeString(locale.identifier)
            .writeByte(UInt8(renderDistance))
            .writeVarInt(chatMode.rawValue)
            .writeBool(chatColorsEnabled)
            .writeByte(skinParts)
            .writeVarInt(mainHand.rawValue)
            .writeBool(filtersText)
            .writeBool(allowsServerListing)
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        self.init(
            locale: Locale(identifier: buf.readString()),
            renderDistance: Int(buf.readByte()),
            chatMode: ChatMode(rawValue: buf.readVarInt()) ?? .enabled,
            chatColorsEnabled: buf.readBool(),
            skinParts: buf.readByte(),
            mainHand: HandType(rawValue: buf.readVarInt()) ?? .right,
            filtersText: buf.readBool(),
            allowsServerListing: buf.readBool()
        )
    }
    
    public enum ChatMode: Int {
        case enabled = 0
        case commands = 1
        case hidden = 2
    }
    
    public enum HandType: Int {
        case left = 0
        case right = 1
    }
}

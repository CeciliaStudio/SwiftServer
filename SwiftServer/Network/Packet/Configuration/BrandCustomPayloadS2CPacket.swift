//
//  BrandCustomPayloadS2CPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class BrandCustomPayloadS2CPacket: Packet {
    public let id: Int = 0x01
    public let identifier: Identifier = .init("custom_payload")
    public let brand: String
    
    public init(brand: String) {
        self.brand = brand
    }
    
    public func encode(to buf: PacketByteBuffer, protocolVersion: Int) {
        buf
            .writeString(Identifier("brand").description)
            .writeString(brand)
    }
    
    public required convenience init(from buf: PacketByteBuffer) {
        let _ = buf.readString()
        self.init(brand: buf.readString())
    }
}

//
//  StatusRequestC2SPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public class StatusRequestC2SPacket: Packet {
    public var id: Int = 0x00
    public var identifier: Identifier = .init("status_request")
    
    public func encode(to buf: PacketByteBuffer, protocolVersion: Int) {
        
    }
    
    public required init(from buf: PacketByteBuffer) {
        
    }
}

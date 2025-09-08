//
//  FinishConfigurationPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class FinishConfigurationPacket: Packet {
    public let id: Int = 0x03
    public let identifier: Identifier = .init("finish_configuration")
    
    public init() {
        
    }
    
    public func encode(to buf: PacketByteBuffer, protocolVersion: Int) {
        
    }
    
    public required init(from buf: PacketByteBuffer) {
        
    }
}

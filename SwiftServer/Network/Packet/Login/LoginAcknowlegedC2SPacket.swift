//
//  LoginAcknowlegedC2SPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public class LoginAcknowlegedC2SPacket: Packet {
    public let id: Int = 0x03
    public let identifier: Identifier = .init("login_acknowleged")
    
    public func encode(to buf: PacketByteBuffer) {
        
    }
    
    public required init(from buf: PacketByteBuffer) {
        
    }
}

//
//  PlayNetworkHandler.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class PlayNetworkHandler: NetworkHandler {
    public var connection: Connection!
    
    init(connection: Connection!) {
        self.connection = connection
    }
    
    public func receivePacket(packet: any Packet) {
        debug(packet.identifier)
    }
}

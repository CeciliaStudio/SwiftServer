//
//  NetworkHandler.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public protocol NetworkHandler {
    var connection: Connection! { get set }
    func receivePacket(packet: any Packet)
}

public extension NetworkHandler {
    func sendPacket(_ packet: any Packet) async throws {
        try await self.connection.sendPacket(packet)
    }
}

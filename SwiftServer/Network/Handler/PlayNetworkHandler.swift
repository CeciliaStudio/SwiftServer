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
        Task {
            try await sendPacket(
                GameJoinS2CPacket(
                    entityID: 0,
                    isHardcore: false,
                    dimensions: [.init("overworld")],
                    maxPlayers: 114514,
                    viewDistance: 8,
                    simulationDistance: 8,
                    reduceDebugInfo: false,
                    showDeathScreen: true,
                    doLimitedCrafting: false,
                    dimensionType: 0,
                    dimensionIdentifier: .init("overworld"),
                    seed: 0,
                    gameMode: .survival
                )
            )
        }
    }
    
    public func receivePacket(packet: any Packet) {
        debug(packet.identifier)
    }
}

//
//  GameJoinS2CPacket.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Foundation

public class GameJoinS2CPacket: Packet {
    public let id: Int = 0x2B
    public let identifier: Identifier = .init("login")
    
    public let entityID: Int
    public let isHardcore: Bool
    public let dimensions: [Identifier]
    public let maxPlayers: Int
    public let viewDistance: Int
    public let simulationDistance: Int
    public let reduceDebugInfo: Bool
    public let showDeathScreen: Bool
    public let doLimitedCrafting: Bool
    public let dimensionType: Int
    public let dimensionIdentifier: Identifier
    public let seed: Int64
    public let gameMode: GameMode
    
    public init(entityID: Int, isHardcore: Bool, dimensions: [Identifier], maxPlayers: Int, viewDistance: Int, simulationDistance: Int, reduceDebugInfo: Bool, showDeathScreen: Bool, doLimitedCrafting: Bool, dimensionType: Int, dimensionIdentifier: Identifier, seed: Int64, gameMode: GameMode) {
        self.entityID = entityID
        self.isHardcore = isHardcore
        self.dimensions = dimensions
        self.maxPlayers = maxPlayers
        self.viewDistance = viewDistance
        self.simulationDistance = simulationDistance
        self.reduceDebugInfo = reduceDebugInfo
        self.showDeathScreen = showDeathScreen
        self.doLimitedCrafting = doLimitedCrafting
        self.dimensionType = dimensionType
        self.dimensionIdentifier = dimensionIdentifier
        self.seed = seed
        self.gameMode = gameMode
    }
    
    public func encode(to buf: PacketByteBuffer) {
        buf
            .writeInt(entityID)
            .writeBool(isHardcore)
            .writeVarInt(dimensions.count)
        for dimension in dimensions {
            buf.writeString(dimension.description)
        }
        buf
            .writeVarInt(maxPlayers)
            .writeVarInt(viewDistance)
            .writeVarInt(simulationDistance)
            .writeBool(reduceDebugInfo)
            .writeBool(showDeathScreen)
            .writeBool(doLimitedCrafting)
            .writeVarInt(dimensionType)
            .writeString(dimensionIdentifier.description)
            .writeLong(seed)
            .writeByte(Byte(gameMode.rawValue))
            .writeByte(255)
            .writeBool(false)
            .writeBool(false)
            .writeBool(false)
            .writeVarInt(0)
            .writeBool(false)
    }
    
    public required init(from buf: PacketByteBuffer) {
        self.entityID = buf.readVarInt()
        self.isHardcore = buf.readBool()
        let dimensionCount = buf.readVarInt()
        var dimensions: [Identifier] = []
        for _ in 0..<dimensionCount {
            dimensions.append(Identifier(rawValue: buf.readString()))
        }
        self.dimensions = dimensions
        self.maxPlayers = buf.readVarInt()
        self.viewDistance = buf.readVarInt()
        self.simulationDistance = buf.readVarInt()
        self.reduceDebugInfo = buf.readBool()
        self.showDeathScreen = buf.readBool()
        self.doLimitedCrafting = buf.readBool()
        self.dimensionType = buf.readVarInt()
        self.dimensionIdentifier = Identifier(rawValue: buf.readString())
        self.seed = buf.readLong()
        self.gameMode = GameMode(rawValue: Int(buf.readByte())) ?? .survival
    }
}

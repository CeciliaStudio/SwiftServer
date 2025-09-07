//
//  NetworkHandler.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation
import Network

public class NetworkHandler: Identifiable, Hashable, Equatable {
    public let id: UUID = .init()
    public let connection: NWConnection
    private var state: State = .handshaking
    
    public init(connection: NWConnection) {
        self.connection = connection
    }
    
    /// 发送一个数据包
    /// 若连接状态异常，会抛出 NetworkError.invalidConnectionState 错误
    /// - Parameter packet: 要发送的数据包
    public func sendPacket(_ packet: any Packet) async throws {
        // 写入 Packet ID 与内容
        let contentBuffer = PacketByteBuffer()
        contentBuffer.writeVarInt(packet.id)
        packet.encode(to: contentBuffer)
        // 在最前面插入长度
        let buf = PacketByteBuffer()
        buf.writeVarInt(contentBuffer.toData().count)
        buf.writeBytes(data: contentBuffer.toData())
        try await sendData(buf.toData())
    }
    
    func receivePacket(_ packet: any Packet) {
        switch packet {
        case let packet as HandshakeC2SPacket: onHandshake(packet: packet)
        case _ as StatusRequestC2SPacket: onStatusRequest()
        case let packet as PingRequestC2SPacket: onPing(packet: packet)
        default:
            warn("\(packet.resourceLocation) 没有对应的处理逻辑，已忽略")
        }
    }
    
    // MARK: - Handshake
    private func onHandshake(packet: HandshakeC2SPacket) {
        debug("接收到握手包 \(packet.protocolVersion)，next state: \(packet.nextState)")
        switch packet.nextState {
        case 1:
            state = .status
        case 2: state = .login
        default: break
        }
    }
    
    // MARK: - Status
    private func onStatusRequest() {
        Task {
            try await self.sendPacket(StatusResponseS2CPacket(players: []))
        }
    }
    
    private func onPing(packet: PingRequestC2SPacket) {
        Task {
            try await self.sendPacket(packet)
        }
    }
    
    private func sendData(_ data: Data) async throws {
        guard connection.state == .ready else {
            throw NetworkError.invalidConnectionState
        }
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            connection.send(content: data, completion: .contentProcessed { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            })
        }
    }
    
    func startReceive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, context, isComplete, error in
            if let data = data, !data.isEmpty {
                self.receiveData(data)
            }
            if isComplete {
                SwiftServer.shared.removeNetworkHandler(id: self.id)
                self.connection.cancel()
            } else {
                self.startReceive()
            }
        }
    }
    
    private func receiveData(_ data: Data) {
        let buf = PacketByteBuffer(data: data)
        let _ = buf.readVarInt()
        let id = buf.readVarInt()
        guard let type = state.packetRegistry.getType(id: id) else {
            warn(String(format: "在 \(state) 中未找到 %x 对应的数据包类型", id))
            return
        }
        receivePacket(type.init(from: buf))
    }
    
    public enum State {
        /// 握手阶段，只处理握手包 (HandshakeC2SPacket)
        case handshaking
        
        /// 状态获取阶段，传输服务器信息和计算延迟
        case status
        
        /// 登录阶段
        case login
        
        /// 游玩阶段，玩家已进入服务器
        case play
        
        public var packetRegistry: PacketRegistry {
            switch self {
            case .handshaking: .handshaking
            case .status: .status
            case .login: .login
            case .play: .play
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: NetworkHandler, rhs: NetworkHandler) -> Bool {
        lhs.id == rhs.id
    }
}

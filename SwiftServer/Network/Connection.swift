//
//  Connection.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation
import Network
import CryptoKit

public class Connection: Identifiable, Hashable, Equatable {
    public let id: UUID = .init()
    public let connection: NWConnection
    public var protocolVersion: Int = ServerMetadata.shared.protocolVersion
    private var networkHandler: NetworkHandler! = DefaultNetworkHandler()
    private var state: State = .handshaking
    
    public init(connection: NWConnection) {
        self.connection = connection
        networkHandler.connection = self
    }
    
    /// 发送一个数据包
    /// 若连接状态异常，会抛出 NetworkError.invalidConnectionState 错误
    /// - Parameter packet: 要发送的数据包
    public func sendPacket(_ packet: any Packet) async throws {
        // 写入 Packet ID 与内容
        let contentBuffer = PacketByteBuffer()
        contentBuffer.writeVarInt(packet.id)
        packet.encode(to: contentBuffer, protocolVersion: protocolVersion)
        // 在最前面插入长度
        let buf = PacketByteBuffer()
        buf.writeVarInt(contentBuffer.toData().count)
        buf.writeBytes(data: contentBuffer.toData())
        try await sendData(buf.toData())
    }
    
    /// 切换当前状态
    /// 若切换到 play 状态，networkHandler 将自动设置为 PlayNetworkHandler
    /// - Parameter state: 目标状态
    public func switchState(_ state: State) {
        if state == .play && self.state != .play {
            self.networkHandler = PlayNetworkHandler(connection: self)
        }
        self.state = state
    }
    
    /// 关闭连接并释放所有对象
    public func close() {
        SwiftServer.shared.removeNetworkHandler(id: self.id)
        self.connection.cancel()
        self.networkHandler = nil
    }
    
    private func receivePacket(_ packet: any Packet) {
        self.networkHandler.receivePacket(packet: packet)
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
                self.close()
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
        
        /// 配置阶段
        case configuration
        
        /// 登录阶段
        case login
        
        /// 游玩阶段，玩家已进入服务器
        case play
        
        public var packetRegistry: PacketRegistry {
            switch self {
            case .handshaking: .handshaking
            case .status: .status
            case .login: .login
            case .configuration: .configuration
            case .play: .play
            }
        }
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Connection, rhs: Connection) -> Bool {
        lhs.id == rhs.id
    }
}

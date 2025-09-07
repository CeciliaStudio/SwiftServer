//
//  main.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation
import Network

public class SwiftServer {
    public static let shared: SwiftServer = SwiftServer()
    private var networkHandlers: [NetworkHandler] = []
    
    public func start() throws {
        PacketRegistry.registerPackets()
        
        let listener = try NWListener(using: .tcp, on: 22597)
        listener.newConnectionHandler = { connection in
            connection.start(queue: .main)
            let handler = NetworkHandler(connection: connection)
            self.networkHandlers.append(handler)
            connection.stateUpdateHandler = { state in
                switch state {
                case .cancelled:
                    self.removeNetworkHandler(id: handler.id)
                case .failed(let error), .waiting(let error):
                    err("连接失败: \(error.localizedDescription)")
                    self.removeNetworkHandler(id: handler.id)
                case .ready:
                    handler.startReceive()
                default:
                    break
                }
            }
        }
        listener.start(queue: .main)
    }
    
    public func removeNetworkHandler(id: UUID) {
        networkHandlers.removeAll { $0.id == id }
    }
}

try SwiftServer.shared.start()
dispatchMain()

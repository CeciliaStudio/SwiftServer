//
//  main.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation
import Network

PacketRegistry.registerPackets()

let listener = try NWListener(using: .tcp, on: 22597)
listener.newConnectionHandler = { connection in
    connection.start(queue: .main)
    let handler = NetworkHandler(connection: connection)
    connection.receive(minimumIncompleteLength: 1, maximumLength: 4096) { data, context, isComplete, error in
        if let data = data, !data.isEmpty {
            handler.receiveData(data)
        }
    }
}
listener.start(queue: .main)
dispatchMain()

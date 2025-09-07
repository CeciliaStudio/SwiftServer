//
//  ServerMetadata.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public struct ServerMetadata: Codable {
    public static let shared: ServerMetadata = .init(version: "1.21", protocolVersion: 767, description: "A Minecraft Server but on §6Swift\n§bhttps://github.com/CeciliaStudio/SwiftServer")
    
    public let version: String
    public let protocolVersion: Int
    public let description: String
}

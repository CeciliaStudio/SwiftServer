//
//  Identifier.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public struct Identifier: CustomStringConvertible {
    public let namespace: String
    public let path: String
    
    public init(namespace: String = "minecraft", _ path: String) {
        self.namespace = namespace
        self.path = path
    }
    
    public init(rawValue: String) {
        let components = rawValue.split(separator: ":").map(String.init)
        if components.count < 2 {
            self.namespace = "minecraft"
            self.path = components.joined(separator: ":")
        } else {
            self.namespace = components[0]
            self.path = components.dropFirst(1).joined(separator: ":")
        }
    }
    
    public var description: String {
        "\(namespace):\(path)"
    }
}

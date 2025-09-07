//
//  Packet.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public protocol Packet {
    /// 将数据包编码并写入到一个 PacketByteBuffer
    /// - Parameter buf: 要写入的 PacketByteBuffer
    func encode(to buf: PacketByteBuffer)
    
    /// 从 PacketByteBuffer 读取并解码数据包
    /// - Parameter buf: 待读取的 PacketByteBuffer
    init(from buf: PacketByteBuffer)
    
    /// 数据包的 Packet ID
    /// 见 https://minecraft.wiki/w/Minecraft_Wiki:Projects/wiki.vg_merge/Protocol?oldid=2789623
    var id: Int { get }
    
    /// 数据包的 Resource Location
    /// 见 https://minecraft.wiki/w/Minecraft_Wiki:Projects/wiki.vg_merge/Protocol?oldid=2789623
    var resourceLocation: String { get }
}

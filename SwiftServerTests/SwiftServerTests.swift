//
//  SwiftServerTests.swift
//  SwiftServerTests
//
//  Created by YiZhiMCQiu on 2025/9/8.
//

import Testing
import MinecraftNBT
import DataTools

struct SwiftServerTests {
    @Test func example() async throws {
        let dataAccumulator = DataAccumulator()
        NBTCompound(contents: ["text": NBTString("REASON")]).append(to: dataAccumulator)
        print(String(data: dataAccumulator.data, encoding: .utf8)!)
    }
}

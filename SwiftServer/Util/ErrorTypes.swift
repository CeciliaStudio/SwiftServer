//
//  ErrorTypes.swift
//  SwiftServer
//
//  Created by YiZhiMCQiu on 2025/9/7.
//

import Foundation

public enum NetworkError: LocalizedError {
    /// 在对 NetworkHandler 进行操作时，若连接未建立 / 已被关闭，则会抛出此错误
    case invalidConnectionState
}

//
//  LogManager.swift
//  PCL.Mac
//
//  Created by YiZhiMCQiu on 2025/5/19.
//

import Foundation

final class LogStore {
    let dateFormatter = DateFormatter()
    static let shared = LogStore()

    private init() {
        dateFormatter.dateFormat = "[yyyy-MM-dd] [HH:mm:ss.SSS]"
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
    }
    
    func append(_ message: String, _ level: String, _ caller: String) {
        print(
            "\(dateFormatter.string(from: Date())) [\(level)] \(caller): \(message)"
        )
    }
}

public struct LogManager {
    public static func log(_ message: Any, file: String = #file, line: Int = #line) {
        LogStore.shared.append(String(describing: message), "INFO", file.split(separator: "/").last! + ":" + String(line))
    }

    public static func warn(_ message: Any, file: String = #file, line: Int = #line) {
        LogStore.shared.append(String(describing: message), "WARN", file.split(separator: "/").last! + ":" + String(line))
    }

    public static func err(_ message: Any, file: String = #file, line: Int = #line) {
        LogStore.shared.append(String(describing: message), "ERROR", file.split(separator: "/").last! + ":" + String(line))
    }

    public static func debug(_ message: Any, file: String = #file, line: Int = #line) {
        LogStore.shared.append(String(describing: message), "DEBUG", file.split(separator: "/").last! + ":" + String(line))
    }
}

public func log(_ message: Any, file: String = #file, line: Int = #line) { LogManager.log(message, file: file, line: line) }
public func warn(_ message: Any, file: String = #file, line: Int = #line) { LogManager.warn(message, file: file, line: line) }
public func err(_ message: Any, file: String = #file, line: Int = #line) { LogManager.err(message, file: file, line: line) }
public func debug(_ message: Any, file: String = #file, line: Int = #line) { LogManager.debug(message, file: file, line: line) }


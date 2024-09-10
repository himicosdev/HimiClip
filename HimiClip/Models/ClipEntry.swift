//
//  ClipEntry.swift
//  HimiClip
//
//  Created by himicoswilson on 9/6/24.
//

import Foundation

// 定义模型，确保遵循 Identifiable 和 Codable 协议
struct ClipEntry: Identifiable, Codable {
    let id: Int?
    let userId: Int?
    var content: String
    let contentType: String?
    let createdAt: String
    let updatedAt: String?
    let username: String?
    
    // 添加一个静态方法来提供默认的 ClipEntry
    static func defaultClip() -> ClipEntry {
        return ClipEntry(id: nil, userId: nil, content: "", contentType: nil, createdAt: "", updatedAt: nil, username: nil)
    }
}

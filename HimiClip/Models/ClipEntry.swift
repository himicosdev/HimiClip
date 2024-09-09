//
//  ClipEntry.swift
//  HimiClip
//
//  Created by himicoswilson on 9/6/24.
//

import Foundation

// 定义模型，确保遵循 Identifiable 和 Decodable 协议
struct ClipEntry: Identifiable, Decodable {
    let id: Int?
    var content: String
    let contentType: String?
    let createdAt: String
    let updatedAt: String?
    
    // 添加一个静态方法来提供默认的 ClipEntry
    static func defaultClip() -> ClipEntry {
        return ClipEntry(id: nil, content: "", contentType: nil, createdAt: "", updatedAt: nil)
    }
}

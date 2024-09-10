//
//  DateFormatterUtility.swift
//  HimiClip
//
//  Created by himicoswilson on 9/7/24.
//

import Foundation
import SwiftUI

struct DateUtility {
    // 静态方法，格式化日期字符串
    static func formattedDate(_ dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"  // 适配 ISO 8601 格式的日期（无毫秒和时区）

        // 将字符串解析为 Date
        if let date = formatter.date(from: dateString) {
            // 格式化为期望的输出格式
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yyyy.MM.dd HH:mm"
            return outputFormatter.string(from: date)
        } else {
            return dateString  // 如果解析失败，返回原始字符串
        }
    }

    // 根据有无 `updatedAt` 或 `createdAt` 显示创建或更新时间的标签，如果都没有则不显示
    static func getDisplayDateLabel(createdAt: String?, updatedAt: String?) -> String? {
        // 只有在 updatedAt 或 createdAt 存在时，才返回格式化的日期标签
        if let updatedAt = updatedAt, !updatedAt.isEmpty {
            return "\(NSLocalizedString("UPDATED_AT", comment: "")) \(formattedDate(updatedAt))"
        } else if let createdAt = createdAt, !createdAt.isEmpty {
            return "\(NSLocalizedString("CREATED_AT", comment: "")) \(formattedDate(createdAt))"
        } else {
            return nil  // 如果没有有效日期，则返回 nil
        }
    }
}

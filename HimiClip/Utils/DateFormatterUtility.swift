//
//  DateFormatterUtility.swift
//  HimiClip
//
//  Created by himicoswilson on 9/7/24.
//

import Foundation
import SwiftUI

struct DateUtility {
    static let iso8601Formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let displayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd HH:mm"
        return formatter
    }()
    
    static func getRelativeTimeDescription(createdAt: String?, updatedAt: String?) -> String {
        let now = currentDateInUTC8()
        
        if let updatedAt = updatedAt, !updatedAt.isEmpty,
           let updatedDate = iso8601Formatter.date(from: updatedAt) {
            return "\(NSLocalizedString("UPDATED_AT", comment: "")) \(formatTime(from: updatedDate, to: now))"
        } else if let createdAt = createdAt, !createdAt.isEmpty,
                  let createdDate = iso8601Formatter.date(from: createdAt) {
            return "\(NSLocalizedString("CREATED_AT", comment: "")) \(formatTime(from: createdDate, to: now))"
        } else {
            return NSLocalizedString("UNKNOWN_TIME", comment: "")
        }
    }
    
    private static func formatTime(from date: Date, to now: Date) -> String {
        let components = Calendar.current.dateComponents([.second, .minute, .hour, .day], from: date, to: now)
        
        if let day = components.day, day > 5 {
            return displayFormatter.string(from: date)
        } else if let day = components.day, day > 0 {
            return "\(day)\(NSLocalizedString("DAYS_AGO", comment: ""))"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)\(NSLocalizedString("HOURS_AGO", comment: ""))"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)\(NSLocalizedString("MINUTES_AGO", comment: ""))"
        } else if let second = components.second, second > 0 {
            return "\(second)\(NSLocalizedString("SECONDS_AGO", comment: ""))"
        } else {
            return NSLocalizedString("JUST_NOW", comment: "")
        }
    }
    
    private static func currentDateInUTC8() -> Date {
        let now = Date()
        return now.addingTimeInterval(TimeInterval(8 * 3600))
    }

    static func currentDateInUTC8String() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Shanghai")
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let fullDateString = dateFormatter.string(from: Date())
        
        // 截取字符串，去掉时区信息和毫秒
        if let dotIndex = fullDateString.firstIndex(of: ".") {
            return String(fullDateString[..<dotIndex])
        }
        
        // 如果没有找到 "."，返回原始字符串
        return fullDateString
    }
}

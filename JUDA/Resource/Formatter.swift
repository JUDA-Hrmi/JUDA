//
//  Formatter.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import Foundation

enum Formatter {
    // 좋아요 숫자 1000 넘으면 k, 1000000 넘으면 m 으로 변경해주는 함수
    static func formattedPostLikesCount(_ count: Int) -> String {
        let numberFormatter = NumberFormatter()
        // 최대, 최소 소수 한자리로 설정
        numberFormatter.minimumFractionDigits = 1
        numberFormatter.maximumFractionDigits = 1
        if count >= 1_000_000 {
            let formattedNumber = Double(count) / 1_000_000.0
            return "\(numberFormatter.string(from: NSNumber(value: formattedNumber)) ?? "")m"
        } else if count >= 1_000 {
            let formattedNumber = Double(count) / 1000.0
            return "\(numberFormatter.string(from: NSNumber(value: formattedNumber)) ?? "")k"
        } else {
            return "\(count)"
        }
    }

    // 평점을 소수점 첫번째 자리까지 String으로 변환해주는 함수
    static func formattedStarRatingCount(rating: Double) -> String {
        String(format: "%.1f", rating)
    }
    
    // 술 도수 소수점 첫번째 자리까지 String으로 변환해주는 함수
    static func formattedABVCount(abv: Double) -> String {
        if abv.truncatingRemainder(dividingBy: 1.0) == 0 {
            return String(Int(abv)) + "%"
        } else {
            return String(format: "%.1f", abv) + "%"
        }
    }
    
    // 현재 시간과 비교하여, x시간 전, x일 전, x주 전, x달 전, x년 전 으로 보여주는 함수
    static func formattedDateBeforeStyle(pastDate: Date) -> String {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .weekOfMonth, .day, .hour, .minute, .second], from: pastDate, to: Date())

        if let year = components.year, year > 0 {
            return "\(year)년 전"
        } else if let month = components.month, month > 0 {
            return "\(month)달 전"
        } else if let week = components.weekOfMonth, week > 0 {
            return "\(week)주 전"
        } else if let day = components.day, day > 0 {
            return "\(day)일 전"
        } else if let hour = components.hour, hour > 0 {
            return "\(hour)시간 전"
        } else if let minute = components.minute, minute > 0 {
            return "\(minute)분 전"
        } else if let second = components.second, second > 0 {
            return "\(second)초 전"
        } else {
            return "방금 전"
        }
    }
}

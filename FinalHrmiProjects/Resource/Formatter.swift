//
//  Formatter.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/29/24.
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
}

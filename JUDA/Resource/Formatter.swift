//
//  Formatter.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 다양한 Formatter 모음
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
    
    // 생년월일 문자열 -> 나이: Int 로 변환
    static func calculateAge(birthdate: String) -> Int? {
        // 생년월일 날짜 변환
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        guard let birthdateDate = dateFormatter.date(from: birthdate) else {
            return nil
        }
        // 생년월일 현재 날짜 사이의 연도 차이 계산
        let calendar = Calendar.current
        let birthdateComponents = calendar.dateComponents([.year, .month, .day], from: birthdateDate)
        let currentDateComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        // 만 나이 X / 예전 한국 나이
        let koreanAge = currentDateComponents.year! - birthdateComponents.year! + 1
        return koreanAge
    }

    // 평점을 소수점 첫번째 자리까지 String으로 변환해주는 함수
    static func formattedStarRatingCount(rating: Double) -> String {
        String(format: "%.1f", rating)
    }
    
    // 술 금액 10000 -> 10,000원 으로 변환해주는 함수
    static func formattedPriceToString(price: Int?) -> String {
        guard price != nil, let price = price else { return "-" }
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""
        guard let formattedPrice = numberFormatter.string(from: NSNumber(value: price)) else { return "\(price)원" }
        return "\(formattedPrice)원"
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
    
    // date 형식을 string 으로 변환
    static func dateToString(date: Date) -> String {
        let myFormatter = DateFormatter()
        myFormatter.dateFormat = "yyyy.MM.dd"  // 변환할 형식
        let dateString = myFormatter.string(from: date)
        return dateString
    }
}

// MARK: - 이미지 관련 Formatter
extension Formatter {
    // 이미지 용량 줄이는 함수
    static func compressImage(_ image: UIImage) -> Data? {
        let maxHeight: CGFloat = 1024.0
        let maxWidth: CGFloat = 1024.0
        let compressionQuality: CGFloat = 0.2

        var actualHeight: CGFloat = image.size.height
        var actualWidth: CGFloat = image.size.width
        var imgRatio: CGFloat = actualWidth / actualHeight
        let maxRatio: CGFloat = maxWidth / maxHeight

        if actualHeight > maxHeight || actualWidth > maxWidth {
            if imgRatio < maxRatio {
                // 세로 길이를 기준으로 크기 조정
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            } else if imgRatio > maxRatio {
                // 가로 길이를 기준으로 크기 조정
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            } else {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }

        UIGraphicsBeginImageContextWithOptions(CGSize(width: actualWidth, height: actualHeight), false, 0.0)
        image.draw(in: CGRect(x: 0, y: 0, width: actualWidth, height: actualHeight))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        guard let resizedImageData = resizedImage?.jpegData(compressionQuality: compressionQuality) else { return nil }
        return resizedImageData
    }
}

// MARK: - Drink 관련 Formatter
extension Formatter {
    // 술 데이터의 상세분류 ( db 에서 type ) 에 따라, 이미지 반환
    // category : 술 종류, detailedCategory : 상세분류
    static func getImageName(category: DrinkType, detailedCategory: String) -> String? {
        switch category {
        // 맥주
        case .beer:
            switch detailedCategory {
            case "흑맥주":
                return "darkBeer.png"
            case "논알콜":
                return "nonAlcoholBeer.png"
            case "과일", "기타":
                return nil
            default: // 나머지 모든 맥주
                return "beer_bottled.png"
            }
        // 우리술
        case .traditional:
            switch detailedCategory {
            case "탁주":
                return "makgeolli.png"
            case "증류주":
                return "distilledAlcohol.png"
            case "약주 청주":
                return "yakju_cheongju.png"
            default: // 기타주류, 과실주
                return nil
            }
        // 위스키
        case .whiskey:
            return "whiskey.png"
        // 와인
        case .wine:
            switch detailedCategory {
            case "주정강화":
                return "fortifiedWine.png"
            case "로제":
                return "roseWine.png"
            case "스파클링":
                return "sparklingWine.png"
            case "화이트":
                return "whiteWine.png"
            case "레드":
                return "redWine.png"
            default: // 예외
                return nil
            }
        default:
            return nil
        }
    }
    
    // 술의 '연령별 선호도' 데이터를 PieModel 형식에 맞게 변환하는 함수
    func getPieModelData(ageData: [String: Int]) -> [PieModel] {
        return [
            .init(type: "20대", count: Double(ageData["20"] ?? 0), color: .mainAccent03),
            .init(type: "30대", count: Double(ageData["30"] ?? 0), color: .mainAccent03.opacity(0.75)),
            .init(type: "40대", count: Double(ageData["40"] ?? 0), color: .mainAccent03.opacity(0.5)),
            .init(type: "50대 이상", count: Double(ageData["50"] ?? 0), color: .mainAccent03.opacity(0.25))
        ]
    }
    
    // 술의 '성별 선호도' 데이터를 PieModel 형식에 맞춰 반환하는 함수
    func getPieModelData(genderData: [String: Int]) -> [PieModel] {
        return [
            .init(type: "남성", count: Double(genderData["male"] ?? 0), color: .mainAccent04),
            .init(type: "여성", count: Double(genderData["female"] ?? 0), color: .mainAccent05.opacity(0.5))
        ]
    }
}

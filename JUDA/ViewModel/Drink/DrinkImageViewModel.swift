//
//  DrinkImageViewModel.swift
//  JUDA
//
//  Created by phang on 2/22/24.
//

import SwiftUI
import FirebaseStorage

// MARK: - Drink Image View Model
@MainActor
final class DrinkImageViewModel: ObservableObject {
    // 이미지 url 스트링 값
    @Published var imageString: String = ""
    // 이미지 가져오고 있는지 체크
    @Published var isLoading: Bool = true
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImages = "drinkImages/"
    
    // 이미지 url string 값 불러오기
    func getImageURLString(category: DrinkType, detailedCategory: String) async {
        if let imageName = getImageName(
                            category: category,
                            detailedCategory: detailedCategory) {
            if let imageString = await fetchImageUrl(imageName: imageName) {
                self.imageString = imageString
            } else {
                self.isLoading = false
            }
        } else {
            self.isLoading = false
        }
    }
    
    // 술 데이터의 상세분류 ( db 에서 type ) 에 따라, 이미지 반환
    // category : 술 종류, detailedCategory : 상세분류
    private func getImageName(category: DrinkType, detailedCategory: String) -> String? {
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
                return nil // TODO: - 수정 필요.
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
}

// MARK: - FireStorage 에서 술 카테고리에 맞는 이미지 가져오기
extension DrinkImageViewModel {
    // 이미지 url 받아오기
    private func fetchImageUrl(imageName: String) async -> String? {
        let reference = storage.reference(withPath: "\(drinkImages)\(imageName)")
        do {
            let url = try await reference.downloadURL()
            return url.absoluteString
        } catch {
            print("Error - fetchImageUrl: \(error.localizedDescription)")
        }
        return nil
    }
}

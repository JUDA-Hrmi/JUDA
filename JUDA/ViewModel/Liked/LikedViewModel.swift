//
//  LikedViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// MARK: - Liked View Model
@MainActor
final class LikedViewModel: ObservableObject {
    // 현재 유저가 좋아요 누른 술 목록
    @Published var likedDrinks = [FBDrink]()
    // 술 이미지 딕셔너리 *[drinkID: imageURL]
    @Published var drinkImages = [String: URL]()
    // 데이터 로딩 중인지 체크
    @Published var isLoading: Bool = true
    // Firestore 경로
    private let firestore = Firestore.firestore()
    private let drinksCollection = "drinks"
    
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImagesPath = "drinkImages/"
    
}

// MARK: - FireStore 에서 데이터 받아오기
extension LikedViewModel {
    // 좋아요 누른 술 목록 가져오기
    func getLikedDrinks(likedDrinksIDList: [String]?) async {
        isLoading = true
        guard let likedDrinksIDList = likedDrinksIDList else {
            print("좋아요 누른 술 없음")
            return
        }
        let drinksReference = firestore.collection(drinksCollection)
        self.likedDrinks.removeAll()
        for drinkID in likedDrinksIDList {
            do {
                let document = try await drinksReference.document(drinkID).getDocument()
                if document.exists {
                    let drink = try document.data(as: FBDrink.self)
                    self.likedDrinks.append(drink)
                    // 술 이미지 받아오기
                    fetchImage(category: DrinkType(rawValue: drink.category) ?? .all,
                                   detailedCategory: drink.type,
                                   drinkID: document.documentID)
                } else {
                    print("Document does not exist")
                }
            } catch {
                print("Error getting drink document: \(error)")
            }
        }
        isLoading = false
    }
}

// MARK: - FireStorage 에서 술 카테고리에 맞는 이미지 가져오기
extension LikedViewModel {
    // 이미지 storage 에서 받아오기
    func fetchImage(category: DrinkType, detailedCategory: String, drinkID: String) {
        guard let imageName = getImageName(category: category,
                                           detailedCategory: detailedCategory) else {
            print("fetchImage - imageName 없음")
            return
        }
        let reference = storage.reference(withPath: "\(drinkImagesPath)\(imageName)")
        reference.downloadURL() { url, error in
            if let error = error {
                print("Error - fetchImageUrl: \(error.localizedDescription)")
            } else {
                self.drinkImages[drinkID] = url
            }
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

//
//  DrinkViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// MARK: - Drink View Model
@MainActor
final class DrinkViewModel: ObservableObject {
    // 술 리스트
    @Published var drinks = [FBDrink]()
    // 술 이미지 딕셔너리 *[drinkID: imageURL]
    @Published var drinkImages = [String: URL]()
    // 그리드 or 리스트
    @Published var selectedViewType: DrinkInfoLayoutOption = .grid
    // 현재 drinks 를 검색할 reference
    @Published var selectedDrinkTypeIndex: Int = 0
    // 현재 drinks 를 정렬할 reference
    @Published var selectedSortedTypeString: String = DrinkSortType.popularity.rawValue
    // pagination 을 위한, 이전 load의 마지막
    @Published var lastSnapshot: QueryDocumentSnapshot?
    // Shimmer Drink List / Grid Cell 을 보여주기 위한
    @Published var isLoading: Bool = true
    // Drink 종류
    let typesOfDrink: [DrinkType] = [
        .all, .traditional, .wine, .whiskey, .beer
    ]
    // FireStore 기본 경로
    private let firestore = Firestore.firestore()
    private let drinkCollection = "drinks"
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImagesPath = "drinkImages/"
    
    // 해당 술의 연령 선호도 를 PieModel 형식에 맞춰 반환
    func getPieModelData(ageData: [String: Int]) -> [PieModel] {
        return [
            .init(type: "20대", count: Double(ageData["20"] ?? 0), color: .mainAccent03),
            .init(type: "30대", count: Double(ageData["30"] ?? 0), color: .mainAccent03.opacity(0.75)),
            .init(type: "40대", count: Double(ageData["40"] ?? 0), color: .mainAccent03.opacity(0.5)),
            .init(type: "50대 이상", count: Double(ageData["50"] ?? 0), color: .mainAccent03.opacity(0.25))
        ]
    }
    
    // 해당 술의 성별 선호도 를 PieModel 형식에 맞춰 반환
    func getPieModelData(genderData: [String: Int]) -> [PieModel] {
        return [
            .init(type: "남성", count: Double(genderData["male"] ?? 0), color: .mainAccent04),
            .init(type: "여성", count: Double(genderData["female"] ?? 0), color: .mainAccent05.opacity(0.5))
        ]
    }
    
    // 선택된 술 카테고리에 따른 reference 설정
    private func getReference(category: DrinkType) -> Query {
        let reference = firestore.collection(drinkCollection)
        switch category {
        case .all:
            print("선택된 술 카테고리 all")
            return reference
        case .beer:
            print("선택된 술 카테고리 beer")
            return reference.whereField("category", isEqualTo: DrinkType.beer.rawValue)
        case .traditional:
            print("선택된 술 카테고리 traditional")
            return reference.whereField("category", isEqualTo: DrinkType.traditional.rawValue)
        case .whiskey:
            print("선택된 술 카테고리 whiskey")
            return reference.whereField("category", isEqualTo: DrinkType.whiskey.rawValue)
        case .wine:
            print("선택된 술 카테고리 wine")
            return reference.whereField("category", isEqualTo: DrinkType.wine.rawValue)
        }
    }
    
    // 술 정렬 방식에 따른 현재 reference 설정
    private func getReference(sortType: DrinkSortType, reference: Query) -> Query {
        switch sortType {
        // 인기순 - 내림차순
        case .popularity:
            print("선택된 술 정렬 방식 popularity")
            return reference.order(by: "rating", descending: true)
        // 도수 높은 순 - 내림차순
        case .highAlcoholContent:
            print("선택된 술 정렬 방식 highAlcoholContent")
            return reference.order(by: "alcohol", descending: true)
        // 도수 낮은 순
        case .lowAlcoholContent:
            print("선택된 술 정렬 방식 lowAlcoholContent")
            return reference.order(by: "alcohol")
        // 금액 높은 순 - 내림차순
        case .highPrice:
            print("선택된 술 정렬 방식 highPrice")
            return reference.order(by: "price", descending: true)
        // 금액 낮은 순
        case .lowPrice:
            print("선택된 술 정렬 방식 lowPrice")
            return reference.order(by: "price")
        }
    }
}

// MARK: - FireStore 에서 술 데이터 불러오기 ( 데이터 20개씩, 페이지네이션 )
extension DrinkViewModel {
    // 술 리스트 - 첫 가져오기 ( 정렬 방식 받아서 사용 )
    func loadDrinksFirstPage() async {
        isLoading = true
        // 술 카테고리 선택에 따라 가져온 reference + 술 정렬 타입에 맞게 collection reference 가져오기
        // pagination 을 위해 limit(to: 20) 추가
        let firstReference = getReference(
                                sortType: DrinkSortType(rawValue: selectedSortedTypeString) ?? .popularity,
                                reference: getReference(category: typesOfDrink[selectedDrinkTypeIndex])
                            ).limit(to: 20)
        do {
            let snapshot = try await firstReference.getDocuments()
            self.drinks.removeAll()
            for document in snapshot.documents {
                if let drink = try? document.data(as: FBDrink.self) {
                    self.drinks.append(drink)
                    // 술 이미지 받아오기
                    fetchImage(category: DrinkType(rawValue: drink.category) ?? .all,
                                   detailedCategory: drink.type,
                                   drinkID: document.documentID)
                } else {
                    print("Error - data(as: FBDrink.self)")
                }
            }
            // lastSnapshot 최신화
            self.lastSnapshot = snapshot.documents.last
        } catch {
            print("Error - load Drinks First Page: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    // 술 리스트 - 다음 페이지 가져오기
    func loadDrinksNextPage() async {
        guard let lastSnapshot = lastSnapshot else {
            print("loadDrinksNextPage - lastSnapshot 없음")
            return
        }
        // 이전 lastSnapshot 이후로 20개
        let reference = getReference(
                            sortType: DrinkSortType(rawValue: selectedSortedTypeString) ?? .popularity,
                            reference: getReference(category: typesOfDrink[selectedDrinkTypeIndex])
                        ).start(afterDocument: lastSnapshot).limit(to: 20)
        do {
            let snapshot = try await reference.getDocuments()
            for document in snapshot.documents {
                if let drink = try? document.data(as: FBDrink.self) {
                    self.drinks.append(drink)
                    // 술 이미지 받아오기
                    fetchImage(category: DrinkType(rawValue: drink.category) ?? .all,
                                   detailedCategory: drink.type,
                                   drinkID: document.documentID)
                } else {
                    print("Error - data(as: FBDrink.self)")
                }
            }
            // lastSnapshot 최신화
            self.lastSnapshot = snapshot.documents.last
        } catch {
            print("Error - load Drinks Next Page: \(error.localizedDescription)")
        }
    }
}

// MARK: - FireStorage 에서 술 카테고리에 맞는 이미지 가져오기
extension DrinkViewModel {
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
}

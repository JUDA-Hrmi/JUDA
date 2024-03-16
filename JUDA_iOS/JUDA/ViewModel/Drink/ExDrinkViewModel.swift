//
//  ExDrinkViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// MARK: - Ex Drink View Model
//@MainActor
//final class ExDrinkViewModel: ObservableObject {
//    // 술 리스트
//    @Published var drinks = [FBDrink]()
//    // 술 이미지 딕셔너리 *[drinkID: imageURL]
//    @Published var drinkImages = [String: URL]()
//    // 첫 접근인지 체크 (첫 접근 시, no image 띄우는 오류때문에 사용)
//    @Published var isFirstAccess = true
//    // 첫 접근때만 사용, url 을 받아올 예정인 개수 (첫 접근 시, no image 띄우는 오류때문에 사용)
//    @Published var intendedURLCount = 0
//    // 그리드 or 리스트
//    @Published var selectedViewType: DrinkInfoLayoutOption = .gridStyle
//    // 현재 drinks 를 검색할 reference
//    @Published var selectedDrinkTypeIndex: Int = 0
//    // 현재 drinks 를 정렬할 reference
//    @Published var selectedSortedTypeString: String = DrinkSortType.popularity.rawValue
//    // pagination 을 위한, 이전 load의 마지막
//    @Published var lastSnapshot: QueryDocumentSnapshot?
//    // Shimmer Drink List / Grid Cell 을 보여주기 위한
//    @Published var isLoading: Bool = true
//    // Drink 종류
//    let typesOfDrink: [DrinkType] = [
//        .all, .traditional, .wine, .whiskey, .beer
//    ]
//    // FireStore 기본 경로
//    private let firestore = Firestore.firestore()
//    private let drinkCollection = "drinks"
//    // FireStorage 기본 경로
//    private let storage = Storage.storage()
//    private let drinkImagesPath = "drinkImages/"
//    
//    
//    // 해당 술의 연령 선호도 를 PieModel 형식에 맞춰 반환
//    func getPieModelData(ageData: [String: Int]) -> [PieModel] {
//        return [
//            .init(type: "20대", count: Double(ageData["20"] ?? 0), color: .mainAccent03),
//            .init(type: "30대", count: Double(ageData["30"] ?? 0), color: .mainAccent03.opacity(0.75)),
//            .init(type: "40대", count: Double(ageData["40"] ?? 0), color: .mainAccent03.opacity(0.5)),
//            .init(type: "50대 이상", count: Double(ageData["50"] ?? 0), color: .mainAccent03.opacity(0.25))
//        ]
//    }
//    
//    // 해당 술의 성별 선호도 를 PieModel 형식에 맞춰 반환
//    func getPieModelData(genderData: [String: Int]) -> [PieModel] {
//        return [
//            .init(type: "남성", count: Double(genderData["male"] ?? 0), color: .mainAccent04),
//            .init(type: "여성", count: Double(genderData["female"] ?? 0), color: .mainAccent05.opacity(0.5))
//        ]
//    }
//    
//    // 선택된 술 카테고리에 따른 reference 설정
//    private func getReference(category: DrinkType) -> Query {
//        let reference = firestore.collection(drinkCollection)
//        switch category {
//        case .all:
//            return reference
//        case .beer:
//            return reference.whereField("category", isEqualTo: DrinkType.beer.rawValue)
//        case .traditional:
//            return reference.whereField("category", isEqualTo: DrinkType.traditional.rawValue)
//        case .whiskey:
//            return reference.whereField("category", isEqualTo: DrinkType.whiskey.rawValue)
//        case .wine:
//            return reference.whereField("category", isEqualTo: DrinkType.wine.rawValue)
//        }
//    }
//    
//    // 술 정렬 방식에 따른 현재 reference 설정
//    private func getReference(sortType: DrinkSortType, reference: Query) -> Query {
//        switch sortType {
//        // 인기순 - 내림차순
//        case .popularity:
//            return reference.order(by: "rating", descending: true)
//        // 도수 높은 순 - 내림차순
//        case .highAlcoholContent:
//            return reference.order(by: "alcohol", descending: true)
//        // 도수 낮은 순
//        case .lowAlcoholContent:
//            return reference.order(by: "alcohol")
//        // 금액 높은 순 - 내림차순
//        case .highPrice:
//            return reference.order(by: "price", descending: true)
//        // 금액 낮은 순
//        case .lowPrice:
//            return reference.order(by: "price")
//        }
//    }
//
//// MARK: - FireStore 에서 술 데이터 불러오기 ( 데이터 20개씩, 페이지네이션 )
//    // 술 리스트 - 첫 가져오기 ( 정렬 방식 받아서 사용 )
//    func loadDrinksFirstPage() async {
//        isLoading = true
//        // 술 카테고리 선택에 따라 가져온 reference + 술 정렬 타입에 맞게 collection reference 가져오기
//        // pagination 을 위해 limit(to: 20) 추가
//        let firstReference = getReference(
//                                sortType: DrinkSortType(rawValue: selectedSortedTypeString) ?? .popularity,
//                                reference: getReference(category: typesOfDrink[selectedDrinkTypeIndex])
//                            ).limit(to: 20)
//        do {
//            let snapshot = try await firstReference.getDocuments()
//            self.drinks.removeAll()
//            if isFirstAccess { intendedURLCount = snapshot.documents.count }
//            for document in snapshot.documents {
//                if let drink = try? document.data(as: FBDrink.self) {
//                    self.drinks.append(drink)
//                    // 술 이미지 받아오기
//                    fetchImage(category: DrinkType(rawValue: drink.category) ?? .all,
//                                   detailedCategory: drink.type,
//                                   drinkID: document.documentID)
//                } else {
//                    print("Error - data(as: FBDrink.self)")
//                }
//            }
//            // lastSnapshot 최신화
//            self.lastSnapshot = snapshot.documents.last
//        } catch {
//            print("Error - load Drinks First Page: \(error.localizedDescription)")
//        }
//        isLoading = false
//    }
//    
//    // 술 리스트 - 다음 페이지 가져오기
//    func loadDrinksNextPage() async {
//        guard let lastSnapshot = lastSnapshot else {
//            print("loadDrinksNextPage - lastSnapshot 없음")
//            return
//        }
//        // 이전 lastSnapshot 이후로 20개
//        let reference = getReference(
//                            sortType: DrinkSortType(rawValue: selectedSortedTypeString) ?? .popularity,
//                            reference: getReference(category: typesOfDrink[selectedDrinkTypeIndex])
//                        ).start(afterDocument: lastSnapshot).limit(to: 20)
//        do {
//            let snapshot = try await reference.getDocuments()
//            for document in snapshot.documents {
//                if let drink = try? document.data(as: FBDrink.self) {
//                    self.drinks.append(drink)
//                    // 술 이미지 받아오기
//                    fetchImage(category: DrinkType(rawValue: drink.category) ?? .all,
//                                   detailedCategory: drink.type,
//                                   drinkID: document.documentID)
//                } else {
//                    print("Error - data(as: FBDrink.self)")
//                }
//            }
//            // lastSnapshot 최신화
//            self.lastSnapshot = snapshot.documents.last
//        } catch {
//            print("Error - load Drinks Next Page: \(error.localizedDescription)")
//        }
//    }
//
//// MARK: - FireStorage 에서 술 카테고리에 맞는 이미지 가져오기
//    // 이미지 uiimage 로 1개만 받아오기
//    func getUIImage(category: DrinkType, detailedCategory: String) async -> UIImage? {
//        guard let imageName = Formatter.getImageName(category: category,
//                                           detailedCategory: detailedCategory) else {
//            print("fetchImage - imageName 없음")
//            return nil
//        }
//        let reference = storage.reference(withPath: "\(drinkImagesPath)\(imageName)")
//        do {
//            let data = try await reference.data(maxSize: 1 * 1024 * 1024)
//            return UIImage(data: data)
//        } catch {
//            print("Error - getUIImage: \(error.localizedDescription)")
//            return nil
//        }
//    }
//    
//    // 이미지 storage 에서 받아오기
//    func fetchImage(category: DrinkType, detailedCategory: String, drinkID: String) {
//        guard let imageName = Formatter.getImageName(category: category,
//                                           detailedCategory: detailedCategory) else {
//            if isFirstAccess { intendedURLCount -= 1 }
//            print("fetchImage - imageName 없음")
//            return
//        }
//        let reference = storage.reference(withPath: "\(drinkImagesPath)\(imageName)")
//        reference.downloadURL() { url, error in
//            if let error = error {
//                print("Error - fetchImageUrl: \(error.localizedDescription)")
//            } else {
//                self.drinkImages[drinkID] = url
//                if self.drinkImages.count == self.intendedURLCount {
//                    self.isFirstAccess = false
//                }
//            }
//        }
//    }
//}

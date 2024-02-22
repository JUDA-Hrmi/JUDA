//
//  DrinkViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - Drink View Model
@MainActor
final class DrinkViewModel: ObservableObject {
    // 술 리스트
    @Published var drinks = [FBDrink]()
    // 그리드 or 리스트
    @Published var selectedViewType: DrinkInfoLayoutOption = .grid
    // 현재 drinks 를 검색할 reference
    @Published var selectedDrinkTypeIndex: Int = 0
    // 현재 drinks 를 정렬할 reference
    @Published var selectedSortedTypeString: String = DrinkSortType.popularity.rawValue
    // pagination 을 위한, 이전 load의 마지막
    @Published var lastSnapshot: QueryDocumentSnapshot?
    
    // Drink 종류
    let typesOfDrink: [DrinkType] = [
        .all, .traditional, .wine, .whiskey, .beer
    ]
    // FireStore 기본 경로
    private let firestore = Firestore.firestore()
    private let drinkCollection = "drinks"
    
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
                } else {
                    print("Error - data(as: FBDrink.self)")
                }
            }
            // lastSnapshot 최신화
            self.lastSnapshot = snapshot.documents.last
        } catch {
            print("Error - load Drinks First Page: \(error.localizedDescription)")
        }
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

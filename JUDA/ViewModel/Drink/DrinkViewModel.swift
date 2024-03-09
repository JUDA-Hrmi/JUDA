//
//  DrinkViewModel.swift
//  JUDA
//
//  Created by phang on 3/8/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// MARK: - Drink View Model
@MainActor
final class DrinkViewModel: ObservableObject {
    // 술 리스트
    @Published var drinks = [Drink]()
    // 그리드 or 리스트
    @Published var selectedViewType: DrinkInfoLayoutOption = .grid
    // 술 종류 선택 segment Index
    @Published var selectedDrinkTypeIndex: Int = 0
    // 술 정렬 방식 선택
    @Published var selectedSortedTypeString: String = DrinkSortType.popularity.rawValue
    // 로딩 중 - Shimmer Drink List / Grid Cell
    @Published var isLoading: Bool = true
    // 술 종류
    let typesOfDrink: [DrinkType] = DrinkType.allCases
    // pagination 을 위한, 이전 load의 마지막 체크
    private var lastSnapshot: QueryDocumentSnapshot?
    // pagination 할 documet 개수
    private let paginationCount = 20
    // FireStore 기본 경로
    private let db = Firestore.firestore()
    private let drinkCollection = "drinks"
    // Firestore Drink Service
    private let firestoreDrinkService = FirestoreDrinkService()
    // AI WellMatch Service - DrinkDetail 의 '어울리는 음식 추천'에서 사용
    private let aiWellMatchService = AIWellMatchService()

    
    // 선택된 술 종류(카테고리)에 따라 Query 설정
    private func getReference(category: DrinkType) -> Query {
        let drinkRef = db.collection(drinkCollection)
        switch category {
        case .all:
            return drinkRef
        case .beer:
            return drinkRef.whereField("category", isEqualTo: DrinkType.beer.rawValue)
        case .traditional:
            return drinkRef.whereField("category", isEqualTo: DrinkType.traditional.rawValue)
        case .whiskey:
            return drinkRef.whereField("category", isEqualTo: DrinkType.whiskey.rawValue)
        case .wine:
            return drinkRef.whereField("category", isEqualTo: DrinkType.wine.rawValue)
        }
    }
    
    // 선택된 술 정렬 방식에 따라 Query 설정
    private func getReference(sortType: DrinkSortType?, query: Query) -> Query {
        switch sortType {
        // 인기순 - 내림차순
        case .popularity:
            return query.order(by: "rating", descending: true)
        // 도수 높은 순 - 내림차순
        case .highAlcoholContent:
            return query.order(by: "alcohol", descending: true)
        // 도수 낮은 순
        case .lowAlcoholContent:
            return query.order(by: "alcohol")
        // 금액 높은 순 - 내림차순
        case .highPrice:
            return query.order(by: "price", descending: true)
        // 금액 낮은 순
        case .lowPrice:
            return query.order(by: "price")
        // default == popularity
        default:
            return query.order(by: "rating", descending: true)
        }
    }
}

// MARK: - 술 데이터 불러오기 / 페이지네이션 ( FirestoreDrinkService )
extension DrinkViewModel {
    // 첫 데이터 20개 가져오기
    func loadDrinksFirstPage() async {
        self.isLoading = true
        let collectionRef = getReference(
            sortType: DrinkSortType(rawValue: selectedSortedTypeString),
            query: getReference(category: typesOfDrink[selectedDrinkTypeIndex]))
            .limit(to: paginationCount)
        do {
            let drinksSnapshot = try await collectionRef.getDocuments()
            self.drinks.removeAll() // 기존 술 배열 비우기
            for drinkDocument in drinksSnapshot.documents {
                let drinkID = drinkDocument.documentID
                let documentRef = db.collection(drinkCollection).document(drinkID)
                let drinkData = try await firestoreDrinkService.fetchDrinkDocument(document: documentRef)
                self.drinks.append(drinkData)
            }
            self.lastSnapshot = drinksSnapshot.documents.last
        } catch {
            print("error :: loadDrinksFirstPage", error.localizedDescription)
        }
        self.isLoading = false
    }
    
    // 추가적인 데이터 가져오기
    func lodaDrinksNextPage() async {
        guard let lastSnapshot = lastSnapshot else {
            print("error :: loadDrinksNextPage - lastSnapshot X")
            return
        }
        let collectionRef = getReference(
            sortType: DrinkSortType(rawValue: selectedSortedTypeString),
            query: getReference(category: typesOfDrink[selectedDrinkTypeIndex]))
            .limit(to: paginationCount)
        do {
            let drinksSnapshot = try await collectionRef.getDocuments()
            for drinkDocument in drinksSnapshot.documents {
                let drinkID = drinkDocument.documentID
                let documentRef = db.collection(drinkCollection).document(drinkID)
                let drinkData = try await firestoreDrinkService.fetchDrinkDocument(document: documentRef)
                self.drinks.append(drinkData)
            }
            self.lastSnapshot = drinksSnapshot.documents.last
        } catch {
            print("error :: lodaDrinksNextPage", error.localizedDescription)
        }
    }
}

// MARK: - DrinkDetail 의 '잘 어울리는 음식' 추천에서 openAI 에게 추천 받아오기
extension DrinkViewModel {
    // openAI 에서 답변 받아오기
    func getFoodRecommendationsToOpenAI(drinkName: String) async -> String {
        let result = await aiWellMatchService.fetchRecommendationsIfNeeded(drinkName: drinkName)
        guard let result = result else { return "-" }
        return result
    }
}

// MARK: - 술 검색에 사용
extension DrinkViewModel {
    // 술 검색해서 데이터 받아오기
    // TODO: - result ( 검색된 술 데이터는 사용처에서 @State 로 사용할 예정 )
    func getSearchedDrinks(from keyword: String) async -> [Drink] {
        self.isLoading = true
        var result = [Drink]()
        do {
            let collectionRef = db.collection(drinkCollection)
            let drinksSnapshot = try await collectionRef.getDocuments()
            for drinkDocument in drinksSnapshot.documents {
                let drinkFieldData = try drinkDocument.data(as: DrinkField.self)
                if drinkFieldData.name.localizedCaseInsensitiveContains(keyword) {
                    let drinkID = drinkDocument.documentID
                    let documentRef = collectionRef.document(drinkID)
                    let drinkData = try await firestoreDrinkService.fetchDrinkDocument(document: documentRef)
                    result.append(drinkData)
                }
            }
        } catch {
            print("error :: getSearchedDrinks", error.localizedDescription)
        }
        self.isLoading = false
        return result
    }
}

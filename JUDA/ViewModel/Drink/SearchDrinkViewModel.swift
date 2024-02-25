//
//  SearchDrinkViewModel.swift
//  JUDA
//
//  Created by phang on 2/25/24.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

@MainActor
class SearchDrinkViewModel: ObservableObject {
    // 검색된 술
    @Published var searchDrinks: [FBDrink] = []
    // 검색된 술 [id: 이미지 url]
    @Published var searchDrinksImageURL: [String: URL] = [:]
    // 로딩 확인
    @Published var isLoading: Bool = false
    // FireStore 기본 경로
    private let db = Firestore.firestore()
    private let drinkCollection = "drinks"
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImagesPath = "drinkImages/"
    
    // 술 검색해서 데이터 받아오기
    func fetchSearchDrinks(from keyword: String) async {
        isLoading = true
        do {
            let snapshot = try await db.collection(drinkCollection).getDocuments()
            searchDrinks.removeAll()
            for document in snapshot.documents {
                let drinkData = try document.data(as: FBDrink.self)
                if drinkData.name.localizedCaseInsensitiveContains(keyword) {
                    self.searchDrinks.append(drinkData)
                    fetchSearchDrinkImage(category: DrinkType(rawValue: drinkData.category) ?? .all,
                                   detailedCategory: drinkData.type,
                                   drinkID: document.documentID)
                }
            }
        } catch {
            print("fetchSearchDrinks - Error")
        }
        isLoading = false
    }
    
    // 검색된 술 이미지 url 가져오기
    private func fetchSearchDrinkImage(category: DrinkType, detailedCategory: String, drinkID: String) {
        guard let imageName = Formatter.getImageName(category: category,
                                           detailedCategory: detailedCategory) else {
            print("fetchSearchDrinkImage - imageName 없음")
            return
        }
        let reference = storage.reference(withPath: "\(drinkImagesPath)\(imageName)")
        reference.downloadURL() { url, error in
            if let error = error {
                print("Error - fetchImageUrl: \(error.localizedDescription)")
            } else {
                self.searchDrinksImageURL[drinkID] = url
            }
        }
    }
}

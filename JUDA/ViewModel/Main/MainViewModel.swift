//
//  MainViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// MARK: - Main View Model
@MainActor
final class MainViewModel: ObservableObject {
    // 인기 있는 술 리스트
    @Published var drinks = [FBDrink]()
    // 인기 있는 술 이미지 딕셔너리 *[drinkID: imageURL]
    @Published var drinkImages = [String: URL]()

    // FireStore 기본 경로
    private let firestore = Firestore.firestore()
    private let drinkCollection = "drinks"
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImagesPath = "drinkImages/"
    
    
    // 인기 있는 술 3개 가져오기
    func getHottestDrink() async {
        let reference = firestore.collection(drinkCollection)
            .order(by: "rating", descending: true).limit(to: 3)
        do {
            let snapshot = try await reference.getDocuments()
            for document in snapshot.documents {
                if let drink = try? document.data(as: FBDrink.self) {
                    self.drinks.append(drink)
                    //
                    print(drink.name)
                    // 술 이미지 받아오기
                    await fetchImage(category: DrinkType(rawValue: drink.category) ?? .all,
                                   detailedCategory: drink.type,
                                   drinkID: document.documentID)
                } else {
                    print("Error - data(as: FBDrink.self)")
                }
            }
        } catch {
            print("Error - load Drinks First Page: \(error.localizedDescription)")
        }
    }
    
    // 이미지 storage 에서 받아오기
    private func fetchImage(category: DrinkType, detailedCategory: String, drinkID: String) async {
        guard let imageName = Formatter.getImageName(category: category,
                                           detailedCategory: detailedCategory) else {
            print("fetchImage - imageName 없음")
            return
        }
        let reference = storage.reference(withPath: "\(drinkImagesPath)\(imageName)")
        do {
            let url = try await reference.downloadURL()
            self.drinkImages[drinkID] = url
            //
            print(drinkID, url)
        } catch {
            print("Error - fetchImageUrl: \(error.localizedDescription)")
        }
    }
}

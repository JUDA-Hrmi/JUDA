//
//  LikedViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

// MARK: - Liked View Model
@MainActor
final class LikedViewModel: ObservableObject {
    // 현재 유저가 좋아요 누른 술 목록
    @Published var likedDrinks = [FBDrink]()
    // 데이터 로딩 중인지 체크
    @Published var isLoading: Bool = false
    // Firestore 경로
    private let firestore = Firestore.firestore()
    private let drinksCollection = "drinks"
    
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
                    let drinkData = try document.data(as: FBDrink.self)
                    self.likedDrinks.append(drinkData)
                    print("Drink Data:", drinkData)
                } else {
                    print("Document does not exist")
                }
            } catch {
                print("Error getting drink document: \(error)")
            }
        }
        isLoading = false
        print("getLikedDrinks", likedDrinks)
    }
}

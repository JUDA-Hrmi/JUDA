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
    // 현재 유저가 좋아요 누른 술상 목록
    @Published var likedPosts = [Post]()
    // 전체 포스트에 사용되는 작성자의 이미지를 갖는 딕셔너리 [포스트ID: 이미지]
    @Published var postUserImages: [String: URL] = [:]
    // 데이터 로딩 중인지 체크
    @Published var isLoading: Bool = true
    // Firestore 경로
    private let firestore = Firestore.firestore()
    private let drinksCollection = "drinks"
    private let postsCollection = "posts"
    
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
    
    // 좋아요 누른 술상 ID 받아서 [PostField] 로 반환
    private func getPostFieldList(to postsIDList: [String]) async -> [PostField] {
        let postReference = firestore.collection(postsCollection)
        var result = [PostField]()
        
        for postID in postsIDList {
            do {
                let document = try await postReference.document(postID).getDocument()
                let postField = try document.data(as: PostField.self)
                result.append(postField)
            } catch {
                print("get Liked Posts Error")
            }
        }
        return result
    }
    
    // 좋아요 누른 술상 목록 가져오기
    func getLikedPosts(likedPostsIDList: [String]?) async {
        guard let likedPostsIDList = likedPostsIDList else {
            print("좋아요 누른 술상 없음")
            return
        }
        isLoading = true
        let postReference = firestore.collection(postsCollection)
        let snapshot = await getPostFieldList(to: likedPostsIDList)
        
        var tasks: [Task<(Int, Post)?, Error>] = []
        for (index, postField) in snapshot.enumerated() {
            let postID = postField.postID ?? ""
            let task = Task<(Int, Post)?, Error> {
                let postDrinkTagRef = postReference.document(postID).collection("drinkTags")
                let drinkTagSnapshot = try await postDrinkTagRef.getDocuments()
                var drinkTags = [DrinkTag]()
                for drinkTag in drinkTagSnapshot.documents {
                    let drinkTagID = drinkTag.documentID
                    let rating = drinkTag.data()["rating"] as! Double
                    if let drinkTagDocument = try await postDrinkTagRef.document(drinkTagID).collection("drink").getDocuments().documents.first {
                        let drinkTagField = try drinkTagDocument.data(as: FBDrink.self)
                        drinkTags.append(DrinkTag(drink: drinkTagField, rating: rating))
                    }
                }
                if let userDocument = try await postReference.document(postID).collection("user").getDocuments().documents.first {
                    let userField = try userDocument.data(as: UserField.self)
                    await userFetchImage(userID: userField.userID ?? "")
                    return (index, Post(userField: userField, drinkTags: drinkTags, postField: postField))
                }
                return nil
            }
            tasks.append(task)
        }
        // 결과를 비동기적으로 수집
        var results: [(Int, Post)] = []
        for task in tasks {
            do {
                if let result = try await task.value {
                    results.append(result)
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        // 원본 문서의 인덱스를 기준으로 결과를 정렬
        results.sort { $0.0 < $1.0 }
        // 인덱스를 제거하고 최종 결과를 추출
        self.likedPosts = results.map { $1 }
        isLoading = false
    }
    
    func userFetchImage(userID: String) async {
        let storageRef = Storage.storage().reference().child("userImages/\(userID)")
        storageRef.downloadURL() { url, error in
            if let error = error {
                print("Error - fetchImageUrl: \(error.localizedDescription)")
            } else {
                self.postUserImages[userID] = url
            }
        }
    }
}

// MARK: - FireStorage 에서 술 카테고리에 맞는 이미지 가져오기
extension LikedViewModel {
    // 이미지 storage 에서 받아오기
    func fetchImage(category: DrinkType, detailedCategory: String, drinkID: String) {
        guard let imageName = Formatter.getImageName(category: category,
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
}

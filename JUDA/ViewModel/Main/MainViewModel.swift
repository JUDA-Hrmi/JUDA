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
    // 인기 있는 술상 리스트
    @Published var posts = [Post]()
    // 전체 포스트에 사용되는 작성자의 이미지를 갖는 딕셔너리 [포스트ID: 이미지]
    @Published var postUserImages: [String: UIImage] = [:]
    
    // FireStore 기본 경로
    private let firestore = Firestore.firestore()
    private let drinkCollection = "drinks"
    private let postCollection = "posts"
    // FireStorage 기본 경로
    private let storage = Storage.storage()
    private let drinkImagesPath = "drinkImages/"
}

// MARK: - 인기 술 가져오기
extension MainViewModel {
    // 인기 있는 술 3개 가져오기
    func getHottestDrinks() async {
        let reference = firestore.collection(drinkCollection)
            .order(by: "rating", descending: true).limit(to: 3)
        do {
            let snapshot = try await reference.getDocuments()
            for document in snapshot.documents {
                if let drink = try? document.data(as: FBDrink.self) {
                    self.drinks.append(drink)
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
        } catch {
            print("Error - fetchImageUrl: \(error.localizedDescription)")
        }
    }
}

// MARK: - 인기 술상 가져오기
extension MainViewModel {
    // 인기 술상 3개 가져오기
    func getHottestPosts() async {
        let postRef = firestore.collection(postCollection)
        let reference = postRef.order(by: "likedCount", descending: true).limit(to: 3)
        var tasks: [Task<(Int, Post)?, Error>] = []
        
        do {
            let snapshot = try await reference.getDocuments()
            for (index, document) in snapshot.documents.enumerated() {
                let task = Task<(Int, Post)?, Error> {
                    let postID = document.documentID
                    let postField = try document.data(as: PostField.self)
                    let postDrinkTagRef = postRef.document(postID).collection("drinkTags")
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
                    if let userDocument = try await postRef.document(postID).collection("user").getDocuments().documents.first {
                        let userField = try userDocument.data(as: UserField.self)
                        await userFetchImage(imageID: userField.userID ?? "")
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
            let posts = results.map { $1 }
            self.posts.append(contentsOf: posts)
        } catch {
            print("posts paging fetch error \(error.localizedDescription)")
        }
    }
    
    func userFetchImage(imageID: String) async {
        let storageRef = Storage.storage().reference().child("userImages/\(imageID)")
        storageRef.getData(maxSize: (1 * 1024 * 1024)) { data, error in
            if let data = data, let uiImage = UIImage(data: data) {
                self.postUserImages[imageID] = uiImage
            } else {
                print("fetch user image error \(String(describing: error?.localizedDescription))")
            }
        }
    }
}

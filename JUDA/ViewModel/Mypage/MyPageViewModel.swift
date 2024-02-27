//
//  MyPageViewModel.swift
//  JUDA
//
//  Created by phang on 2/26/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

// MARK: - MyPageViewModel
@MainActor
class MyPageViewModel: ObservableObject {
    // 해당 유저의 술상 리스트
    @Published var notifications = [NotificationField]()
    @Published var postUserImages = [String: UIImage]()
    @Published var userPosts = [Post]()
    // 데이터 로딩 중인지 체크
    @Published var isLoading: Bool = true
    
    @Published var likedUserID: String = ""
    @Published var postId: String = ""
    @Published var likedTime: Date = Date()
    @Published var userName: String = ""
    
    // Firestore 경로
    private let firestore = Firestore.firestore()
    private let usersCollection = "users"
    private let postsCollection = "posts"
}

// MARK: - 유저가 작성한 술상 가져오기
extension MyPageViewModel {
    // 유저가 작성한 post 에 접근
    func getUsersPosts(userID: String) async {
        let userReference = firestore.collection(usersCollection)
        isLoading = true
        do {
            let userPostRef = userReference.document(userID).collection("posts")
            let userPostSnapshot = try await userPostRef.getDocuments()
            await fetchPost(userPostSnapshot: userPostSnapshot)
        } catch {
            print("get Users Posts error \(error.localizedDescription)")
        }
    }
    
    // post 데이터 가져오기
    private func fetchPost(userPostSnapshot: QuerySnapshot) async {
        var tasks: [Task<(Int, Post)?, Error>] = []
        let postReference = firestore.collection(postsCollection)
        
        for (index, document) in userPostSnapshot.documents.enumerated() {
            let task = Task<(Int, Post)?, Error> {
                let postID = document.documentID
                let postField = try document.data(as: PostField.self)
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
        self.userPosts = results.map { $1 }
        isLoading = false
    }
}


extension MyPageViewModel {
    func fetchNotificationList(userId: String) async {
        do {
            let alarmSnapshot = try await firestore.collection("users").document(userId).collection("notificationList").getDocuments()
            
            self.notifications.removeAll()
            
            for alarmDocument in alarmSnapshot.documents {
                if let notification = try? alarmDocument.data(as: NotificationField.self) {
                    self.notifications.append(notification)
                    print("notification: ", notification)
                }
            }
            print(notifications)
        } catch {
            print("Error fetching posts:", error)
        }
    }
    
    func sendLikeNotification(_ postUserId: String, to notificationField: NotificationField) async {
        try? firestore.collection("users").document(postUserId).collection("notificationList").document(UUID().uuidString).setData(from: notificationField)
    }
}

extension MyPageViewModel {
    
}

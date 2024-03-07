//
//  FirebaseUserViewModel.swift
//  JUDA
//
//  Created by phang on 3/6/24.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// MARK: - Firebase : User
@MainActor
final class FirebaseUserViewModel {
    // Firestore - db 연결
    private let db = Firestore.firestore()
    private let userCollection = "users"
    private let postCollection = "posts"
    private let likedPostCollection = "likedPosts"
    private let likedDrinkCollection = "likedDrinks"
    private let notificationCollection = "notifications"
    // Firebase Post ViewModel
    private let firestorePostViewModel = FirestorePostViewModel()
    // Firebase Drink ViewModel
    private let firestoreDrinkViewModel = FirestorePostViewModel()
    
    
    // firestore 에서 UserField 정보 가져오기
    func fetchUserFieldData(uid: String) async throws -> UserField {
        do {
            let document = try await db.collection(userCollection).document(uid).getDocument(source: .cache)
            let userData = try document.data(as: UserField.self)
            return userData
        } catch {
            throw FetchUserError.userField
        }
    }
    
    // 해당 유저가 작성한 post 리스트 받아오기
    func fetchUserWrittenPosts(uid: String) async throws -> [Post] {
        let userWrittenPostRef = db.collection(userCollection).document(uid).collection(postCollection)
        // TODO: - Post 가져오는 코드
        //        firestorePostViewModel.
        return []
    }
    
    // 해당 유저가 좋아요 누른 post 리스트 받아오기
    func fetchUserLikedPosts(uid: String) async throws -> [Post] {
        let userLikedPostRef = db.collection(userCollection).document(uid).collection(likedPostCollection)
        // TODO: - Post 가져오는 코드
//        firestorePostViewModel.
        return []
    }
    
    // 해당 유저가 좋아요 누른 drink 리스트 받아오기
    func fetchUserLikedDrink(uid: String) async throws -> [Drink] {
        let userLikedDrinkRef = db.collection(userCollection).document(uid).collection(likedDrinkCollection)
        // TODO: - Drink 가져오는 코드
//        firestoreDrinkViewModel.
        return []
    }
    
    // 해당 유저의 notification 리스트 받아오기
    func fetchUserNotifications(uid: String) async throws -> [UserNotification] {
        do {
            let userNotificationRef = db.collection(userCollection).document(uid).collection(notificationCollection)
            let userNotificationSnapshot = try await userNotificationRef.getDocuments()
            for notificationDocument in userNotificationSnapshot.documents {
                let notificationFieldData = try notificationDocument.data(as: NotificationField.self)
                let notificationID = notificationDocument.documentID
                let notificationPostRef = userNotificationRef.document(notificationID).collection(likedPostCollection)
                // TODO: - notification 해당 post 가져오는 코드
            }
            return []
        } catch let error {
            throw error
        }
    }
}

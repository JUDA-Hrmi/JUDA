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
    private let firestoreDrinkViewModel = FirestoreDrinkViewModel()
    
    
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
        // Post 가져오는 코드 - FirestorePostViewModel
        let userWrittenPostList = try await fetchPostCollection(collection: userWrittenPostRef)
        return userWrittenPostList
    }
    
    // 해당 유저가 좋아요 누른 post 리스트 받아오기
    func fetchUserLikedPosts(uid: String) async throws -> [Post] {
        let userLikedPostRef = db.collection(userCollection).document(uid).collection(likedPostCollection)
        // Post 가져오는 코드 - FirestorePostViewModel
        let userLikedPostList = try await fetchPostCollection(collection: userLikedPostRef)
        return userLikedPostList
    }
    
    // 해당 유저가 좋아요 누른 drink 리스트 받아오기
    func fetchUserLikedDrink(uid: String) async throws -> [Drink] {
        let userLikedDrinkRef = db.collection(userCollection).document(uid).collection(likedDrinkCollection)
        // Drink 가져오는 코드 - FirestoreDrinkViewModel
        let userLikedPostList = try await fetchDrinkCollection(collection: userLikedDrinkRef)
        return userLikedPostList
    }
    
    // 해당 유저의 notification 리스트 받아오기
    func fetchUserNotifications(uid: String) async throws -> [UserNotification] {
        do {
            var result = [UserNotification]()
            let userNotificationRef = db.collection(userCollection).document(uid).collection(notificationCollection)
            let userNotificationSnapshot = try await userNotificationRef.getDocuments()
            for notificationDocument in userNotificationSnapshot.documents {
                let notificationFieldData = try notificationDocument.data(as: NotificationField.self)
                let notificationID = notificationDocument.documentID
                let notificationPostRef = userNotificationRef.document(notificationID).collection(likedPostCollection)
                // notification 해당되는 post 가져오는 코드 - FirestorePostViewModel
                let notificationPostList = try await fetchPostCollection(collection: notificationPostRef)
                // post는 원래 리스트가 아니라 1개. 하지만, postID 가 필요해서 리스트로 받은 뒤 first 추출
                guard let notificationPostData = notificationPostList.first else {
                    throw PostError.documentFetch
                }
                result.append(UserNotification(notificationField: notificationFieldData,
                                               likedPost: notificationPostData))
            }
            return result
        } catch let error {
            throw error
        }
    }
    
    // Post 리스트를 가져오는 함수
    // Post 를 단일로 가져오는 firestorePostViewModel 의 fetchPostDocument 을 사용.
    private func fetchPostCollection(collection: CollectionReference) async throws -> [Post] {
        do {
            var result = [Post]()
            // Post 가져오는 코드 - FirestorePostViewModel
            let snapshot = try await collection.getDocuments()
            for document in snapshot.documents {
                let id = document.documentID
                let documentRef = collection.document(id)
                let postData = try await firestorePostViewModel.fetchPostDocument(document: documentRef)
                result.append(postData)
            }
            return result
        } catch let error {
            print("error :: fetchPostCollection", error.localizedDescription)
            throw PostError.collectionFetch
        }
    }
    
    // Drink 리스트를 가져오는 함수
    // Drink 를 단일로 가져오는 firestoreDrinkViewModel 의 fetchDrinkDocument 을 사용.
    private func fetchDrinkCollection(collection: CollectionReference) async throws -> [Drink] {
        do {
            var result = [Drink]()
            // Drink 가져오는 코드 - FirestoreDrinkViewModel
            let snapshot = try await collection.getDocuments()
            for document in snapshot.documents {
                let id = document.documentID
                let drinkData = try await firestoreDrinkViewModel.fetchDrinkDocument(ref: collection, drinkID: id)
                result.append(drinkData)
            }
            return result
        } catch let error {
            print("error :: fetchDrinkCollection", error.localizedDescription)
            throw DrinkFetchError.drinkCollection
        }
    }
}

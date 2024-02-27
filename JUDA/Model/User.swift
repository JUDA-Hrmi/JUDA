//
//  User.swift
//  JUDA
//
//  Created by phang on 2/15/24.
//

import Foundation
import FirebaseFirestore

// Firebase users 컬렉션 데이터 모델
struct User {
    let userField: UserField
    let posts: [Post]
    let userNotification: [String: NotificationField]
}

// Firebase users 컬렉션 필드 데이터 모델
struct UserField: Codable {
	@DocumentID var userID: String?
    let name: String
    let age: Int
    let gender: String
    let notificationAllowed: Bool
    var likedPosts: [String]?
    var likedDrinks: [String]?
}

// Firebase users/notificationList 컬렉션 데이터 모델
struct NotificationField: Codable, Hashable {
    let likedUserName: String
    let likedUserId: String
    let postId: String
    let thumbnailImageURL: URL?
    let likedTime: Date
}


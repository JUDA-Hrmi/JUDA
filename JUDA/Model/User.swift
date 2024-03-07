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
    var userField: UserField
    var posts: [Post]
    var likedPosts: [Post]
    var likedDrinks: [Drink]
    var notifications: [UserNotification]
}

// Firebase users 컬렉션 필드 데이터 모델
struct UserField: Codable {
	@DocumentID var userID: String?
    var name: String
    var age: Int
    var gender: String
    var notificationAllowed: Bool
    var profileImageURL: URL
    var authProviders: String // AuthProviderOption - rawValue
}

struct UserNotification {
    var notificationField: NotificationField
    var likedUser: User
    var likedPost: Post
}

// Firebase users/notificationList 컬렉션 데이터 모델
struct NotificationField: Codable, Hashable {
    var isChecked: Bool
    var likedTime: Date
    var thumbnailImageURL: URL?
}


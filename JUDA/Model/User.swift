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
	let likedPosts: [Post]
	let likedDrinks: [Drink]
	let notifications: [UserNotification]
}

// Firebase users 컬렉션 필드 데이터 모델
struct UserField: Codable {
	@DocumentID var userID: String?
    var name: String
    var age: Int
    let gender: String
    var notificationAllowed: Bool
    var profileImageURL: URL
//    var authProviders: [AuthProviderOption]
}

struct UserNotification {
	let notificationField: NotificationField
	let likedUser: User
	let likedPost: Post
}

// Firebase users/notificationList 컬렉션 데이터 모델
struct NotificationField: Codable, Hashable {
	let isChecked: Bool
	let likedTime: Date
	let thumbnailImageURL: URL?
}


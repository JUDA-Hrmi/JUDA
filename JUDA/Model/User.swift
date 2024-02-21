//
//  User.swift
//  JUDA
//
//  Created by phang on 2/15/24.
//

import Foundation

// Firebase users 컬렉션 데이터 모델
struct User {
    let userField: UserField
    let posts: [String: Post]
    let userNotification: [String: NotificationField]
}

// Firebase users 컬렉션 필드 데이터 모델
struct UserField: Codable {
    let name: String
    let age: Int
    let gender: String
    let notificationAllowed: Bool
    var likedPosts: [String]?
    var likedDrinks: [String]?
}

// Firebase users/notificationList 컬렉션 데이터 모델
struct NotificationField: Codable {
    var isChecked: Bool
    let likedUserID: String
    let likedUserName: String
    let likedTime: Date
}

//
//  User.swift
//  JUDA
//
//  Created by phang on 2/15/24.
//

import Foundation

// MARK: - User 모델
struct User: Codable, Hashable {
    var name: String
    var age: Int
    var gender: String
    var profileImage: String?
    var notificationAllowed: Bool
}

// MARK: - Notification 모델
// TODO: 추후 수정 필요
struct Alarm: Codable, Hashable {
    var isChecked: Bool
    let likedUser: String
    let likedTime: Date
    let likeUserUID: String
}

//
//  Post.swift
//  JUDA
//
//  Created by 정인선 on 2/20/24.
//

import Foundation
import FirebaseFirestore

// Firebase posts 컬렉션 데이터 모델
struct Post {
	var postField: PostField
	var likedUsersID: [String] // collection
}

// Firebase posts 컬렉션 필드 데이터 모델
struct PostField: Codable {
    @DocumentID var postID: String?
    var user: WrittenUser
    var drinkTags: [DrinkTag]
    var imagesURL: [URL]
    var content: String
    var foodTags: [String]
    var postedTime: Date
    var likedCount: Int
}

// post 작성한 유저 데이터
struct WrittenUser: Codable {
    var userID: String
    var userName: String
    var userAge: Int
    var userGender: String
    var userProfileImageURL: URL?
}

// post 에 태그된 술 데이터
struct DrinkTag: Codable {
    var drinkID: String
    var drinkName: String
    var drinkAmount: String
    var drinkRating: Double
}

extension Post: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.postField.postID)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.postField.postID == rhs.postField.postID
    }
}

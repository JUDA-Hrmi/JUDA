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
	var user: User
    var drinkTags: [Drink]
	var likedUsersID: [String]
    var postField: PostField
}

// Firebase posts 컬렉션 필드 데이터 모델
struct PostField: Codable {
	@DocumentID var postID: String?
	var drinkRatings: [String: Double]
    var imagesURL: [URL]
	var content: String
	var foodTags: [String]
	var postedTime: Date
}

extension Post: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.postField.postID)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        return lhs.postField.postID == rhs.postField.postID
    }
}

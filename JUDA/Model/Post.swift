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
	var userField: UserField
    var drinkTags: [DrinkTag]?
    var postField: PostField
}

// Firebase posts 컬렉션 필드 데이터 모델
struct PostField: Codable {
	@DocumentID var postID: String?
    var imagesURL: [URL]
	var content: String
	var likedCount: Int
    var postedTimeStamp: Date
	var foodTags: [String]
}

// Firebase posts/drinkTags 컬렉션 데이터 모델
struct DrinkTag: Codable {
    let drink: FBDrink
	let rating: Double
}

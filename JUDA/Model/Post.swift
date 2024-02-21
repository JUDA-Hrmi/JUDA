//
//  Post.swift
//  JUDA
//
//  Created by 정인선 on 2/20/24.
//

import Foundation

// Firebase posts 컬렉션 데이터 모델
struct Post {
    var user: (String, UserField)
    var drinkTags: [String: DrinkTag]
    var postField: PostField?
}

// Firebase posts 컬렉션 필드 데이터 모델
struct PostField: Codable {
    let imagesID: [String]
    let content: String
    let likedCount: Int
    let postedTimeStamp: Date
    let foodTags: [String]
}

// Firebase posts/drinkTags 컬렉션 데이터 모델
struct DrinkTag: Codable {
    let drinkTag: FBDrink
    let rating: Double
}

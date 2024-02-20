//
//  Post.swift
//  JUDA
//
//  Created by 정인선 on 2/20/24.
//

import Foundation

struct Post {
    var user: (String, User)
    var tagDrinks: [String: TagDrink]
    var postField: PostField?
}

struct PostField: Codable {
    let images: [String]
    let content: String
    let likedCount: Int
    let postedTimeStamp: Date
    let tagFoods: [String]
}

struct TagDrink: Codable {
    let tagDrink: FBDrink
    let rating: Double
}

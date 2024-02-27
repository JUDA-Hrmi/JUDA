//
//  Drink.swift
//  JUDA
//
//  Created by Minjae Kim on 2/20/24.
//

import Foundation
import FirebaseFirestore

// MARK: - 술의 카테고리
enum DrinkType: String {
    case all = "전체"
    case traditional = "우리술"
    case beer = "맥주"
    case wine = "와인"
    case whiskey = "위스키"
}

// MARK: - Firebase에서 사용하는 Drink Model
struct FBDrink: Codable, Hashable {
	@DocumentID var drinkID: String?
	let category: String
	let type: String
	let name: String
	let amount: String
	let price: Int
	let alcohol: Double
	let country: String
	let province: String? // wine
	let aroma: [String]? // wine, beer, whishkey
	let taste: [String]? // wine, beer, whishkey
	let finish: [String]? // wine, beer, whishkey
	let sweet: Int? // traditional
	let sour: Int? // traditional
	let refresh: Int? // traditional
	let body: Int? // traditional
	let carbonated: Int? // traditional
    let material: [String]?  // traditional
	let wellMatched: [String]
	let rating: Double
    let taggedPostID: [String]
	let agePreference: [String: Int]
	let genderPreference: [String: Int]

    static let dummyData = FBDrink(
        category: "와인", type: "레드", name: "맥매니스, 캘리포니아 피노 누아",
        amount: "750ml", price: 65000, alcohol: 13.5,
        country: "미국", province: "캘리포니아",
        aroma: ["딸기잼", "체리"], taste: ["바닐라", "크림", "블루베리"], finish: ["깔끔한"],
        sweet: nil, sour: nil, refresh: nil, body: nil, carbonated: nil, material: nil,
        wellMatched: ["치즈", "오리고기"], rating: 4.1,
        taggedPostID: ["z", "s"], agePreference: ["20": 42, "30": 72, "40": 40, "50": 19],
        genderPreference: ["female": 68, "male": 40 ])
}

//
//  Drink.swift
//  JUDA
//
//  Created by Minjae Kim on 2/20/24.
//

import Foundation
import FirebaseFirestore

struct Drink {
	let drinkField: DrinkField
	let taggedPosts: [Post]
	let agePreference: AgePreference
	let genderPreference: GenderPreference
	let likedUsersID: [String]
}

// MARK: - Firebase에서 사용하는 Drink Model
struct DrinkField: Codable, Hashable {
	@DocumentID var drinkID: String?
    let drinkImageURL: URL?
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
}

// MARK: - Firestore AgePreferenceUID Collection에 해당하는 Document 갯수
struct AgePreference {
	var twenty: Int
	var thirty: Int
	var fourty: Int
	var fifty: Int
}

// MARK: - Firestore GenderPreferenceUID Collection에 해당하는 Document 갯수
struct GenderPreference {
	var male: Int
	var female: Int
}

// MARK: Drink - Hashable
extension Drink: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.drinkField.drinkID)
    }
    
    static func == (lhs: Drink, rhs: Drink) -> Bool {
        return lhs.drinkField.drinkID == rhs.drinkField.drinkID
    }
}

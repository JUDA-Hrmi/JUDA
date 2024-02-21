//
//  Drink.swift
//  JUDA
//
//  Created by Minjae Kim on 2/20/24.
//

import Foundation

enum DrinkJsonType: CaseIterable {
	case beer, wine, traditional, whiskey
	
	var jsonName: String {
		switch self {
		case .beer:
			return "Beer_food"
		case .wine:
			return "test_wine"
		case .traditional:
			return "traditional_liqur_food"
		case .whiskey:
			return "test_whiskey"
		}
	}
}

// Firebase에서 사용하는 Drink Model
struct FBDrink: Codable {
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
	let wellMatched: [String]
	let rating: Double
	let taggedCount: Int
	let agePreference: [Int: Int]
	let genderPreference: [String: Int]
}

struct RawBeer: Codable {
	let category: String
	let type: String
	let name: String
	let amount: String
	let price: Int
	let alcohol: Double
	let country: String
	let aroma: [String]
	let taste: [String]
	let finish: [String]
	let wellMatched: [String]
}

struct RawTraditional: Codable {
	let category: String
	let type: String
	let name: String
	let amount: String
	let price: Int
	let alcohol: Double
	let country: String
	let sweet: Int
	let sour: Int
	let refresh: Int
	let body: Int
	let carbonated: Int
	let wellMatched: [String]
}

struct RawWine: Codable {
	let category: String
	let type: String
	let name: String
	let amount: String
	let price: Int
	let alcohol: Double
	let country: String
	let province: String
	let aroma: [String]
	let taste: [String]
	let finish: [String]
	let wellMatched: [String]
}

struct RawWhiskey: Codable {
	let category: String
	let type: String
	let name: String
	let amount: String
	let price: Int
	let alcohol: Double
	let country: String
	let aroma: [String]
	let taste: [String]
	let finish: [String]
	let wellMatched: [String]
}

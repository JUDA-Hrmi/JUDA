//
//  DrinkUploadViewModel.swift
//  JUDA
//
//  Created by Minjae Kim on 2/20/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

final class DrinkUploadViewModel: ObservableObject {
	func decodeJsonUploadFirestore() {
		var drinks: [FBDrink] = []
		for drinkType in DrinkJsonType.allCases {
			if let drinkData = mapFirebaseDrink(drinkType: drinkType) {
				drinks.append(contentsOf: drinkData)
			}
		}
		drinkDataUpload(drinkData: drinks)
	}
	
	func jsonLoad(drinkType: DrinkJsonType) -> Data? {
		guard let jsonLocation = Bundle.main.url(forResource: drinkType.jsonName, withExtension: "json") else { return nil }
		do {
			let data = try Data(contentsOf: jsonLocation)
			return data
		} catch {
			print("error:: \(drinkType.jsonName) jsonLoad")
			return nil
		}
	}
	
	func mapFirebaseDrink(drinkType: DrinkJsonType) -> [FBDrink]? {
		guard let jsonData = jsonLoad(drinkType: drinkType) else { return nil }
		
		let agePreference = [10: 0, 20: 0, 30: 0, 40: 0]
		let genderPreference = ["male": 0, "female": 0]
		
		switch drinkType {
		case .beer:
			guard let drinkData = try? JSONDecoder().decode([RawBeer].self, from: jsonData) else {
				print("error decoding \(drinkType)")
				return nil }
			return drinkData.map {
				FBDrink(category: $0.category, type: $0.type, name: $0.name, amount: $0.amount,
							  price: $0.price, alcohol: $0.alcohol, country: $0.country, province: nil,
							  aroma: $0.aroma, taste: $0.taste, finish: $0.finish,
							  sweet: nil, sour: nil, refresh: nil, body: nil, carbonated: nil,
							  wellMatched: $0.wellMatched, rating: 0, taggedCount: 0, agePreference: agePreference,
							  genderPreference: genderPreference)
			}
		case .traditional:
			guard let drinkData = try? JSONDecoder().decode([RawTraditional].self, from: jsonData) else {
				print("error decoding \(drinkType)")
				return nil }
			return drinkData.map {
				FBDrink(category: $0.category, type: $0.type, name: $0.name, amount: $0.amount,
							  price: $0.price, alcohol: $0.alcohol, country: $0.country, province: nil,
							  aroma: nil, taste: nil, finish: nil,
							  sweet: $0.sweet, sour: $0.sour, refresh: $0.refresh, body: $0.body, carbonated: $0.carbonated,
							  wellMatched: $0.wellMatched, rating: 0, taggedCount: 0, agePreference: agePreference,
							  genderPreference: genderPreference)
			}
		case .whiskey:
			guard let drinkData = try? JSONDecoder().decode([RawWhiskey].self, from: jsonData) else {
				print("error decoding \(drinkType)")
				return nil }
			return drinkData.map {
				FBDrink(category: $0.category, type: $0.type, name: $0.name, amount: $0.amount,
							  price: $0.price, alcohol: $0.alcohol, country: $0.country, province: nil,
							  aroma: $0.aroma, taste: $0.taste, finish: $0.finish,
							  sweet: nil, sour: nil, refresh: nil, body: nil, carbonated: nil,
							  wellMatched: $0.wellMatched, rating: 0, taggedCount: 0, agePreference: agePreference,
							  genderPreference: genderPreference)
			}
		case .wine:
			guard let drinkData = try? JSONDecoder().decode([RawWine].self, from: jsonData) else {
				print("error decoding \(drinkType)")
				return nil }
			return drinkData.map {
				FBDrink(category: $0.category, type: $0.type, name: $0.name, amount: $0.amount,
							  price: $0.price, alcohol: $0.alcohol, country: $0.country, province: $0.province,
							  aroma: $0.aroma, taste: $0.taste, finish: $0.finish,
							  sweet: nil, sour: nil, refresh: nil, body: nil, carbonated: nil,
							  wellMatched: $0.wellMatched, rating: 0, taggedCount: 0, agePreference: agePreference,
							  genderPreference: genderPreference)
			}
		}
	}
	
	func drinkDataUpload(drinkData: [FBDrink]) {
		let db = Firestore.firestore()
		do {
			let drinkRef = db.collection("drinks")
			for drink in drinkData {
				let documentPath = UUID().uuidString
				try drinkRef.document(documentPath).setData(from: drink)
			}
		} catch {
			print("drink firestore upload error")
		}
	}
}

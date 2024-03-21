////
////  DrinkUploadViewModel.swift
////  JUDA
////
////  Created by Minjae Kim on 2/20/24.
////
//
//import Foundation
//import FirebaseCore
//import FirebaseFirestore
//
//@MainActor
//final class DrinkUploadViewModel: ObservableObject {
//	private let fireStorageService = FireStorageService()
//	
//	func decodeJsonUploadFirestore() async {
//		var drinks: [DrinkField] = []
//		for drinkType in DrinkJsonType.allCases {
//			if let drinkData = await mapFirebaseDrink(drinkJsonType: drinkType) {
//				drinks.append(contentsOf: drinkData)
//			}
//		}
//		print(drinks.filter { $0.category == "위스키" }.count)
//		print(drinks.filter { $0.category == "우리술" }.count)
//		print(drinks.filter { $0.category == "맥주" }.count)
//		print(drinks.filter { $0.category == "와인" }.count)
//		drinkDataUpload(drinkData: drinks)
//	}
//	
//	private func jsonLoad(drinkJsonType: DrinkJsonType) -> Data? {
//		guard let jsonLocation = Bundle.main.url(forResource: drinkJsonType.jsonName, withExtension: "json") else { return nil }
//		do {
//			let data = try Data(contentsOf: jsonLocation)
//			return data
//		} catch {
//			print("error:: \(drinkJsonType.jsonName) jsonLoad")
//			return nil
//		}
//	}
//	
//	private func getDrinkType(drinkJsonType: DrinkJsonType) -> DrinkType {
//		switch drinkJsonType {
//		case .beer:
//			return .beer
//		case .wine:
//			return .wine
//		case .traditional:
//			return .traditional
//		case .whiskey:
//			return .whiskey
//		}
//	}
//	
//	private func mapFirebaseDrink(drinkJsonType: DrinkJsonType) async -> [DrinkField]? {
//		guard let jsonData = jsonLoad(drinkJsonType: drinkJsonType) else { return nil }
//		
//		var imagesURL = [URL?]()
//		
//		switch drinkJsonType {
//		case .beer:
//			guard let drinkData = try? JSONDecoder().decode([RawBeer].self, from: jsonData) else {
//				print("error decoding \(drinkJsonType)")
//				return nil
//			}
//			imagesURL = await fetchImagesURL(drinkJsonType: drinkJsonType, drinkData: drinkData)
//			return drinkData.enumerated().map {
//				return DrinkField(drinkImageURL: imagesURL[$0.offset], category: $0.element.category, type: $0.element.type,
//								  name: $0.element.name, amount: $0.element.amount, price: $0.element.price, alcohol: $0.element.alcohol,
//								  country: $0.element.country, province: nil, aroma: $0.element.aroma, taste: $0.element.taste,
//								  finish: $0.element.finish, sweet: nil, sour: nil, refresh: nil, body: nil,
//								  carbonated: nil, material: nil, wellMatched: $0.element.wellMatched, rating: 0)
//			}
//		case .traditional:
//			guard let drinkData = try? JSONDecoder().decode([RawTraditional].self, from: jsonData) else {
//				print("error decoding \(drinkJsonType)")
//				return nil
//			}
//			imagesURL = await fetchImagesURL(drinkJsonType: drinkJsonType, drinkData: drinkData)
//			return drinkData.enumerated().map {
//				return DrinkField(drinkImageURL: imagesURL[$0.offset], category: $0.element.category, type: $0.element.type,
//								  name: $0.element.name, amount: $0.element.amount, price: $0.element.price, alcohol: $0.element.alcohol,
//								  country: $0.element.country, province: nil, aroma: nil, taste: nil, finish: nil,
//								  sweet: $0.element.sweet, sour: $0.element.sour, refresh: $0.element.refresh, body: $0.element.body,
//								  carbonated: $0.element.carbonated, material: $0.element.material,
//								  wellMatched: $0.element.wellMatched, rating: 0)
//			}
//		case .whiskey:
//			guard let drinkData = try? JSONDecoder().decode([RawWhiskey].self, from: jsonData) else {
//				print("error decoding \(drinkJsonType)")
//				return nil
//			}
//			imagesURL = await fetchImagesURL(drinkJsonType: drinkJsonType, drinkData: drinkData)
//			return drinkData.enumerated().map {
//				return DrinkField(drinkImageURL: imagesURL[$0.offset], category: $0.element.category, type: $0.element.type,
//								  name: $0.element.name, amount: $0.element.amount, price: $0.element.price, alcohol: $0.element.alcohol,
//								  country: $0.element.country, province: nil, aroma: $0.element.aroma, taste: $0.element.taste,
//								  finish: $0.element.finish, sweet: nil, sour: nil, refresh: nil, body: nil,
//								  carbonated: nil, material: nil, wellMatched: $0.element.wellMatched, rating: 0)
//			}
//		case .wine:
//			guard let drinkData = try? JSONDecoder().decode([RawWine].self, from: jsonData) else {
//				print("error decoding \(drinkJsonType)")
//				return nil
//			}
//			imagesURL = await fetchImagesURL(drinkJsonType: drinkJsonType, drinkData: drinkData)
//			return drinkData.enumerated().map {
//				return DrinkField(drinkImageURL: imagesURL[$0.offset], category: $0.element.category, type: $0.element.type,
//								  name: $0.element.name, amount: $0.element.amount, price: $0.element.price, alcohol: $0.element.alcohol,
//								  country: $0.element.country, province: $0.element.province, aroma: $0.element.aroma,
//								  taste: $0.element.taste, finish: $0.element.finish, sweet: nil, sour: nil, refresh: nil,
//								  body: nil, carbonated: nil, material: nil,
//								  wellMatched: $0.element.wellMatched, rating: 0)
//			}
//		}
//	}
//	
//	private func fetchImagesURL<T: RawDrink>(drinkJsonType: DrinkJsonType, drinkData: [T]) async -> [URL?] {
//		let category = getDrinkType(drinkJsonType: drinkJsonType)
//		
//		return await withTaskGroup(of: (Int, URL?).self) { group in
//			for (index, drink) in drinkData.enumerated() {
//				group.addTask {
//					do {
//						if let fileName = Formatter.getImageName(category: category, detailedCategory: drink.type) {
//							let url = try await self.fireStorageService.fetchImageURL(folder: .drink, fileName: fileName)
//							return (index, url)
//						} else {
//							print("error :: getImageName", drink.category, drink.type)
//							return (index, nil)
//						}
//					} catch {
//						print("error :: fetchImageURL", error.localizedDescription)
//						return (index, nil)
//					}
//				}
//			}
//			
//			var result = [(Int, URL?)]()
//			for await downloadURL in group {
//				result.append(downloadURL)
//			}
//			return result.sorted(by: { $0.0 < $1.0 }).map { $0.1 }
//		}
//	}
//	
//	private func drinkDataUpload(drinkData: [DrinkField]) {
//		let db = Firestore.firestore()
//		do {
//			let drinkRef = db.collection("drinks")
//			for drink in drinkData {
//				let documentPath = UUID().uuidString
//				try drinkRef.document(documentPath).setData(from: drink)
//			}
//		} catch {
//			print("drink firestore upload error")
//		}
//	}
//}
//
//protocol RawDrink: Codable {
//	var category: String { get }
//	var type: String { get }
//	var name: String { get }
//	var amount: String { get }
//	var price: Int { get }
//	var alcohol: Double { get }
//	var country: String { get }
//}
//
//// MARK: struct & enum
//extension DrinkUploadViewModel {
//	private struct RawBeer: RawDrink {
//		let category: String
//		let type: String
//		let name: String
//		let amount: String
//		let price: Int
//		let alcohol: Double
//		let country: String
//		let aroma: [String]
//		let taste: [String]
//		let finish: [String]
//		let wellMatched: [String]
//	}
//
//	private struct RawTraditional: RawDrink {
//		let category: String
//		let type: String
//		let name: String
//		let amount: String
//		let price: Int
//		let alcohol: Double
//		let country: String
//		let sweet: Int
//		let sour: Int
//		let refresh: Int
//		let body: Int
//		let carbonated: Int
//		let material: [String]
//		let wellMatched: [String]
//	}
//
//	private struct RawWine: RawDrink {
//		let category: String
//		let type: String
//		let name: String
//		let amount: String
//		let price: Int
//		let alcohol: Double
//		let country: String
//		let province: String
//		let aroma: [String]
//		let taste: [String]
//		let finish: [String]
//		let wellMatched: [String]
//	}
//
//	private struct RawWhiskey: RawDrink {
//		let category: String
//		let type: String
//		let name: String
//		let amount: String
//		let price: Int
//		let alcohol: Double
//		let country: String
//		let aroma: [String]
//		let taste: [String]
//		let finish: [String]
//		let wellMatched: [String]
//	}
//
//	// MARK: -
//	private enum DrinkJsonType: CaseIterable {
//		case beer, wine, traditional, whiskey
//		
//		var jsonName: String {
//			switch self {
//			case .beer:
//				return "BeerTest"
//			case .traditional:
//				return "TraditionalTest"
//			case .whiskey:
//				return "WhiskeyTest"
//			case .wine:
//				return "WineTest"
//			}
//		}
//	}
//}

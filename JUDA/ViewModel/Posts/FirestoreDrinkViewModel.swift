//
//  FirestoreDrinkViewModel.swift
//  JUDA
//
//  Created by Minjae Kim on 3/5/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

enum Age: String, CaseIterable {
	case twenty = "20"
	case thirty = "30"
	case fourty = "40"
	case fifty = "50"
}

@MainActor
final class FirestoreDrinkViewModel {
	private let db = Firestore.firestore()
	private let firestorePostViewModel = FirestorePostViewModel()
	
	// drinks collection의 Field Data 불러오는 메서드
	// 불러오지 못 할 수 있어 return type은 optional type
	func fetchDrinkField(ref: CollectionReference, drinkID: String) async -> DrinkField? {
		do {
			return try await ref.document(drinkID).getDocument(as: DrinkField.self)
		} catch {
			print("error :: fetchDrinkField() -> fetch drink field data failure")
			print(error.localizedDescription)
			return nil
		}
	}
	
	// drinks/agePreferenceUID collection
	// 각 '연령대'에 맞는 document에 접근하여 UsersID collection에 해당하는 ducument의 갯수를 count
	func fetchAgePreferenceUID(ref: CollectionReference) async -> AgePreference {
		let ages = Age.allCases
		var agePreference = AgePreference(twenty: 0, thirty: 0, fourty: 0, fifty: 0)
		
		do {
			for age in ages {
				switch age {
				case .twenty:
					agePreference.twenty = try await ref.document(age.rawValue).collection("usersID").getDocuments().count
					break
				case .thirty:
					agePreference.thirty = try await ref.document(age.rawValue).collection("usersID").getDocuments().count
					break
				case .fourty:
					agePreference.fourty = try await ref.document(age.rawValue).collection("usersID").getDocuments().count
					break
				case .fifty:
					agePreference.fifty = try await ref.document(age.rawValue).collection("usersID").getDocuments().count
					break
				}
			}
		} catch {
			print("error :: fetchAgePreferenceUID() -> fetch agePreferece collection data failure")
			print(error.localizedDescription)
		}
		return agePreference
	}
	
	// drinks/genderPreferenceUID collection
	// 각 '성별'에 맞는 document에 접근하여 UsersID collection에 해당하는 ducument의 갯수를 count
	func fetchGenderPreferenceUID(ref: CollectionReference) async -> GenderPreference {
		let genders = Gender.allCases
		var genderPreference = GenderPreference(male: 0, female: 0)
		
		do {
			for gender in genders {
				switch gender {
				case .male:
					genderPreference.male = try await ref.document(gender.rawValue).collection("usersID").getDocuments().count
				case .female:
					genderPreference.female = try await ref.document(gender.rawValue).collection("usersID").getDocuments().count
				}
			}
		} catch {
			print("error :: fetchGenderPreferenceUID() -> fetch genderPreferece collection data failure")
			print(error.localizedDescription)
		}
		return genderPreference
	}
	
	// drinks/likedUsersID collection
	// 위 collection에 해당하는 ducument의 갯수를 count
	func fetchLikedCount(ref: CollectionReference) async -> Int {
		do {
			return try await ref.getDocuments().count
		} catch {
			print("error :: fetchLikedCount() -> fetch likedUsersID collection data failure")
			print(error.localizedDescription)
		}
		return 0
	}
	
	// drinks collection field data update 메서드
	func updateDrinkField(ref: CollectionReference, drinkID: String, data: [String: Any]) async -> Bool {
		do {
			try await ref.document(drinkID).updateData(data)
			return true
		} catch {
			print("error :: drinkFieldUpdate() -> update drink field data failure")
			print(error.localizedDescription)
			return false
		}
	}
}

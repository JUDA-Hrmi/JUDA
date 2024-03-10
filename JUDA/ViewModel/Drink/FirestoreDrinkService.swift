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

enum DrinkError: Error {
	case fetchDrinkField
    case fetchDrinkDocument
    case fetchDrinkCollection
    case delete
}

@MainActor
final class FirestoreDrinkService {
    // Firestore Post Service
	private let firestorePostService = FirestorePostService()
}

// MARK: Firestore Fetch Data
extension FirestoreDrinkService {
    // Drink 리스트를 가져오는 함수
    // Drink 를 단일로 가져오는 firestoreDrinkViewModel 의 fetchDrinkDocument 을 사용.
    func fetchDrinkCollection(collection: CollectionReference) async throws -> [Drink] {
        do {
            var result = [Drink]()
            // Drink 가져오는 코드 - FirestoreDrinkViewModel
            let snapshot = try await collection.getDocuments()
            for document in snapshot.documents {
                let id = document.documentID
                let documentRef = collection.document(id)
                let drinkData = try await fetchDrinkDocument(document: documentRef)
                result.append(drinkData)
            }
            return result
        } catch let error {
            print("error :: fetchDrinkCollection", error.localizedDescription)
            throw DrinkError.fetchDrinkCollection
        }
    }
    
	// drinks collection의 document data 불러오는 메서드
	// 불러오지 못 할 경우 error를 throw
	func fetchDrinkDocument(document: DocumentReference) async throws -> Drink {
		do {
			let taggedPostsRef = document.collection("taggedPosts")
			let agePreferenceUIDRef = document.collection("agePreferenceUID")
			let genderPreferenceUIDRef = document.collection("genderPreferenceUID")
			let likedUsersIDRef = document.collection("likedUsersID")
			
			let drikField = try await fetchDrinkField(document: document)
			let taggedPosts = await fetchTaggedPosts(ref: taggedPostsRef)
			let agePreference = await fetchAgePreferenceUID(ref: agePreferenceUIDRef)
			let genderPreference = await fetchGenderPreferenceUID(ref: genderPreferenceUIDRef)
			let likedUsersID = await fetchDrinkLikedUsersID(ref: likedUsersIDRef)
			
			return Drink(drinkField: drikField, 
						 taggedPosts: taggedPosts,
						 agePreference: agePreference,
						 GenderPreference: genderPreference, 
						 likedUsersID: likedUsersID)
		} catch DrinkError.fetchDrinkField {
			print("error :: fetchDrinkField() -> fetch drink field data failure")
			throw DrinkError.fetchDrinkField
		} catch {
			print("error :: fetchDrinkField() -> fetch drink field data failure")
			print(error.localizedDescription)
			throw DrinkError.fetchDrinkDocument
		}
	}
	
	// drinks collection의 하위 collection인 taggedPosts document data 불러오는 메서드
	// 불러오지 못 할 경우 배열에 추가 x
	func fetchTaggedPosts(ref: CollectionReference) async -> [Post] {
		var taggedPosts = [Post]()
		
		do {
			let snapshot = try await ref.getDocuments()
			for document in snapshot.documents {
				let documentRef = document.reference
				let taggedPost = try await firestorePostService.fetchPostDocument(document: documentRef)
				
				taggedPosts.append(taggedPost)
			}
		} catch {
			print("error :: fetchTaggedPosts() -> fetch taggedPost document data failure")
			print(error.localizedDescription)
		}
		return taggedPosts
	}
	
	// drinks collection의 Field data 불러오는 메서드
	// 불러오지 못 할 경우 error를 throw
	func fetchDrinkField(document: DocumentReference) async throws -> DrinkField {
		do {
			return try await document.getDocument(as: DrinkField.self)
		} catch {
			print(error.localizedDescription)
			throw DrinkError.fetchDrinkField
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
	func fetchDrinkLikedUsersID(ref: CollectionReference) async -> [String] {
        var likedUsersID = [String]()
        do {
            let snapshot = try await ref.getDocuments()
            for document in snapshot.documents {
                let userID = document.documentID
                likedUsersID.append(userID)
            }
        } catch {
            print("error :: fetchDrinkLikedUsersID() -> fetch Drink likedUsersID collection data failure")
            print(error.localizedDescription)
        }
        return likedUsersID
	}
}

// MARK: Firestore drink field data update
extension FirestoreDrinkService {
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

// MARK: Firestore drink document delete
extension FirestoreDrinkService {
    // drinks collection에서 삭제하고싶은 drink에 해당하는 document 삭제 메서드
    func deleteDrinkDocument(document: DocumentReference) async throws {
        do {
            try await document.delete()
        } catch {
            print("error :: deleteDrinkDocument() -> delete drink document data failure")
            print(error.localizedDescription)
            throw DrinkError.delete
        }
    }
}

// MARK: Firestore drink document upload
extension FirestoreDrinkService {
    // likedUsersID 하위 컬렉션에 업로드
    func uploadDrinkLikedUsersID(collection: CollectionReference, uid: String) async {
        do {
            try await collection.document(uid).setData([:])
        } catch {
            print("error :: uploadDrinkLikedUsersID() -> upload drink liked users id data failure")
            print(error.localizedDescription)
        }
    }
}

//
//  FirestorePostViewModel.swift
//  JUDA
//
//  Created by Minjae Kim on 3/5/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

enum PostFetchError: Error {
	case postDocument, postField
}

@MainActor
final class FirestorePostViewModel {}

// MARK: Firestore Fetch Data
extension FirestorePostViewModel {
	// posts collection의 post document data 불러오는 메서드
	// 불러오지 못 할 수 경우 error throw
	func fetchPostDocument(ref: CollectionReference, postID: String) async throws -> Post {
		do {
			let postField = try await fetchPostField(ref: ref, postID: postID)
			let likedUsersID: [String] = await fetchPostLikedUsersID(ref: ref, postID: postID)
			return Post(postField: postField, likedUsersID: likedUsersID)
		} catch PostFetchError.postField {
			print("error :: fetchPostField() -> fetch post field data failure")
			throw PostFetchError.postField
		} catch {
			print("error :: fetchPostDocument() -> fetch post document data failure")
			throw PostFetchError.postDocument
		}
	}
	
	// posts collection의 Field data 불러오는 메서드
	// 불러오지 못 할 수 경우 error throw
	func fetchPostField(ref: CollectionReference, postID: String) async throws -> PostField {
		do {
			return try await ref.document(postID).getDocument(as: PostField.self)
		} catch {
			print(error.localizedDescription)
			throw PostFetchError.postField
		}
	}
	
	// posts collection의 하위 collection likedUsersID의 id 전부 불러오는 메서드
	// fetch 에러를 던질 시, 해당 값을 배열에 추가되지 않음
	func fetchPostLikedUsersID(ref: CollectionReference, postID: String) async -> [String] {
		var likedUsersID = [String]()
		do {
			let snapshot = try await ref.document(postID).collection("likedUsersID").getDocuments()
			for document in snapshot.documents {
				let userID = document.documentID
				likedUsersID.append(userID)
			}
		} catch {
			print("error :: fetchPostLikedUsersID() -> fetch post likedUsersID collection data failure")
			print(error.localizedDescription)
		}
		return likedUsersID
	}
}

// MARK: Firestore post document delete
extension FirestorePostViewModel {
	// posts collection에서 삭제하고싶은 post에 해당하는 document 삭제 메서드
	func deletePostDocument(postID: String) async -> Bool {
		let postRef = Firestore.firestore().collection("posts")
		do {
			try await postRef.document(postID).delete()
			return true
		} catch {
			print("error :: postDelete() -> delete post document data failure")
			print(error.localizedDescription)
			return false
		}
	}
}

// MARK: Firestore post field data update
extension FirestorePostViewModel {
	// posts collection에서 수정하고싶은 post에 해당하는 field data 업데이트 메서드
	func updatePostField(ref: CollectionReference, postID: String, data: [String: Any]) async -> Bool {
		do {
			try await ref.document(postID).updateData(data)
			return true
		} catch {
			print("error :: postFieldUpdate() -> update post field data failure")
			print(error.localizedDescription)
			return false
		}
	}
}

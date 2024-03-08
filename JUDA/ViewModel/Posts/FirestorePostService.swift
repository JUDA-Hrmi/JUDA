//
//  FirestorePostViewModel.swift
//  JUDA
//
//  Created by Minjae Kim on 3/5/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

enum PostError: Error {
    case fieldFetch
    case documentFetch
    case collectionFetch
    case upload
    case update
    case delete
}

@MainActor
final class FirestorePostService {}

// MARK: Firestore Fetch Data
extension FirestorePostService {
	// posts collection의 post document data 불러오는 메서드
	// 불러오지 못 할 수 경우 error throw
	func fetchPostDocument(document: DocumentReference) async throws -> Post {
		do {
			let postField = try await fetchPostField(document: document)
			let likedUsersIDRef = document.collection("likedUsersID")
			let likedUsersID: [String] = await fetchPostLikedUsersID(ref: likedUsersIDRef)
			
			return Post(postField: postField, likedUsersID: likedUsersID)
		} catch PostError.fieldFetch {
//			print("error :: fetchPostField() -> fetch post field data failure")
			throw PostError.fieldFetch
		} catch {
//			print("error :: fetchPostDocument() -> fetch post document data failure")
			throw PostError.documentFetch
		}
	}
	
	// posts collection의 Field data 불러오는 메서드
	// 불러오지 못 할 수 경우 error throw
	func fetchPostField(document: DocumentReference) async throws -> PostField {
		do {
			return try await document.getDocument(as: PostField.self)
		} catch {
			print(error.localizedDescription)
			throw PostError.fieldFetch
		}
	}
	
	// posts collection의 하위 collection likedUsersID의 id 전부 불러오는 메서드
	// fetch 에러를 던질 시, 해당 값을 배열에 추가되지 않음
	func fetchPostLikedUsersID(ref: CollectionReference) async -> [String] {
		var likedUsersID = [String]()
		
		do {
			let snapshot = try await ref.getDocuments()
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

//MARK: Firestore post document upload
extension FirestorePostService {
	func uploadPostDocument(post: Post) async throws {
		let postID = UUID().uuidString
		let postDocumentRef = Firestore.firestore().collection("posts").document(postID)
		let likedUsersIDCollectionRef = postDocumentRef.collection("likedUsersID")
		
		do {
			try postDocumentRef.setData(from: post.postField, merge: true)
			for userID in post.likedUsersID {
				do {
					try await likedUsersIDCollectionRef.document(userID).setData([:])
				} catch {
					print("error :: uploadPostDocument() -> upload post likedUsersID collection data failure")
					print(error.localizedDescription)
//					continue
				}
			}
		} catch {
			print("error :: uploadPostDocument() -> upload post document data failure")
			print(error.localizedDescription)
			throw PostError.upload
		}
	}
}

// MARK: Firestore post document delete
extension FirestorePostService {
	// posts collection에서 삭제하고싶은 post에 해당하는 document 삭제 메서드
	func deletePostDocument(postID: String) async throws {
		let postsRef = Firestore.firestore().collection("posts")
		
		do {
			try await postsRef.document(postID).delete()
		} catch {
			print("error :: deletePostDocument() -> delete post document data failure")
			print(error.localizedDescription)
			throw PostError.delete
		}
	}
}

// MARK: Firestore post field data update
extension FirestorePostService {
	// posts collection에서 수정하고싶은 post에 해당하는 field data 업데이트 메서드
	func updatePostField(ref: CollectionReference, postID: String, data: [String: Any]) async throws {
		do {
			try await ref.document(postID).updateData(data)
		} catch {
			print("error :: updatePostField() -> update post field data failure")
			print(error.localizedDescription)
			throw PostError.update
		}
	}
}

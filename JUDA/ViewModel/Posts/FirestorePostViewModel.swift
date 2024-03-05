//
//  FirestorePostViewModel.swift
//  JUDA
//
//  Created by Minjae Kim on 3/5/24.
//

import Foundation
import FirebaseCore
import FirebaseFirestore

@MainActor
final class FirestorePostViewModel {
	private let db = Firestore.firestore()
	
	func fetchPostField(ref: CollectionReference, postID: String) async -> PostField? {
		do {
			return try await ref.document(postID).getDocument(as: PostField.self)
		} catch {
			print("error :: fetchPostField() -> fetch post field data failure")
			print(error.localizedDescription)
			return nil
		}
	}
	
	func deletePostDocument(postID: String) async -> Bool {
		let postRef = db.collection("posts")
		do {
			try await postRef.document(postID).delete()
			return true
		} catch {
			print("error :: postDelete() -> delete post document data failure")
			print(error.localizedDescription)
			return false
		}
	}
	
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

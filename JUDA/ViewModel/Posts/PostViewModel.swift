//
//  PostService.swift
//  JUDA
//
//  Created by Minjae Kim on 3/8/24.
//

import SwiftUI
import FirebaseFirestore

@MainActor
final class PostViewModel: ObservableObject {
	// 파이어베이스 연결
	private let db = Firestore.firestore()
	private let firestorePostService = FirestorePostService()
	private let firestoreDrinkService = FirestoreDrinkService()
	
	// 게시글 객체 배열
	@Published var posts = [Post]()
	// 마지막 포스트 확인용(페이징)
	@Published var lastQuerydocumentSnapshot: QueryDocumentSnapshot?
	// 게시글 불러오기 또는 삭제 작업이 진행중인지 나타내는 상태 프로퍼티
	@Published var isLoading = false
}

// MARK: Fetch
extension PostViewModel {
	func getPostSortType(postSortType: PostSortType) -> Query {
		let postRef = db.collection("posts")
		
		switch postSortType {
		case .popularity:
			return postRef.order(by: "likedCount", descending: true)
		case .mostRecent:
			return postRef.order(by: "postedTimeStamp", descending: true)
		}
	}
	
	func firstFetchPost(query: Query) async {
		do {
			let firstSnapshot = try await query.limit(to: 20).getDocuments()
			lastQuerydocumentSnapshot = firstSnapshot.documents.last
			isLoading = true
			await fetchPosts(querySnapshots: firstSnapshot)
		} catch {
			print("posts paging fetch error \(error.localizedDescription)")
		}
	}
	
	func nextFetchPost(query: Query) async {
		guard let lastQuerydocumentSnapshot = lastQuerydocumentSnapshot else { return }
		do {
			let nextSnapshot = try await query.limit(to: 20).start(afterDocument: lastQuerydocumentSnapshot).getDocuments()
			self.lastQuerydocumentSnapshot = nextSnapshot.documents.last
			await fetchPosts(querySnapshots: nextSnapshot)
		} catch {
			print("posts paging fetch error \(error.localizedDescription)")
		}
	}
	
	func fetchPosts(querySnapshots: QuerySnapshot) async {
		var tasks: [Task<(Int, Post)?, Error>] = []
		let postRef = db.collection("posts")
		
		for (index, document) in querySnapshots.documents.enumerated() {
			let task = Task<(Int, Post)?, Error> {
				do {
					let post = try await firestorePostService.fetchPostDocument(document: document.reference)
					return (index, post)
				} catch PostError.fieldFetch {
					print("error :: fetchPostField() -> fetch post field data failure")
					return nil
				} catch PostError.documentFetch {
					print("error :: fetchPostDocument() -> fetch post document data failure")
					return nil
				}
			}
			tasks.append(task)
		}
		
		var results = [(Int, Post)]()
		for task in tasks {
			do {
				if let result = try await task.value {
					results.append(result)
				}
			} catch {
				print(error.localizedDescription)
			}
		}
		results.sort { $0.0 < $1.0 }
		
		let posts = results.map { $0.1 }
		
		self.posts.append(contentsOf: posts)
		self.isLoading = false
	}
}

// MARK: delete
extension PostViewModel {
	
}

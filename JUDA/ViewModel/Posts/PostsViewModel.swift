//
//  PostsViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import FirebaseCore
import FirebaseStorage
import FirebaseFirestore

enum LikedActionType {
	case plus, minus
}

enum FireStorageImageFolderType: CaseIterable {
	case fcm, drink, post, postThumbnail, user
	
	var description: String {
		switch self {
		case .fcm:
			"FCMImages"
		case .drink:
			"drinkImages"
		case .post:
			"postImages"
		case .postThumbnail:
			"postImages"
		case .user:
			"userImages"
		}
	}
}

// MARK: - 술상 정렬 enum
enum PostSortType: String, CaseIterable {
	case popularity = "인기"
	case mostRecent = "최신"
}

final class PostsViewModel: ObservableObject {
	// 파이어베이스 연결
	private let db = Firestore.firestore()
	// 게시글 객체 배열 생성
	@Published var posts = [Post]()
	// 마지막 포스트 확인용(페이징)
	@Published var lastQuerydocumentSnapshot: QueryDocumentSnapshot?
	// 전체 포스트에 사용되는 이미지를 갖는 튜플 형태의 배열을 갖고있는 딕셔너리 [포스트ID: [(이미지ID, 이미지)]]
	@Published var postImages: [String: [(imageID: String, uiImage: UIImage)]] = [:]
	@Published var postThumbnailImages: [String: UIImage] = [:]
	// 전체 포스트에 사용되는 작성자의 이미지를 갖는 딕셔너리 [포스트ID: 이미지]
	@Published var postUserImages: [String: UIImage] = [:]
	// 게시글 검색 텍스트
	@Published var postSearchText = ""
	// 게시글 정렬 타입
	// 게시글 정렬용 세그먼트 인덱스
	@Published var selectedSegmentIndex = 0
	// 게시글 불러오는 동안 보여줄 임시 로딩뷰 바인딩용 프로퍼티
	@Published var postSortType = PostSortType.allCases
	@Published var isLoading = false
}

// MARK: Fetch
extension PostsViewModel {
	@MainActor
	func getMiddleIndex() -> Int {
		return 0
	}
	
	func getPostSortType(postSortType: PostSortType) -> Query {
		let postRef = db.collection("posts")
		switch postSortType {
		case .popularity:
			return postRef
				.order(by: "likedCount", descending: true)
		case .mostRecent:
			return postRef
				.order(by: "postedTimeStamp", descending: true)
		}
	}
	
	@MainActor
	func firstFetchPost(query: Query) async {
		let clock = ContinuousClock()
		let time = await clock.measure {
			do {
				let firstSnapshot = try await query.limit(to: 20).getDocuments()
				lastQuerydocumentSnapshot = firstSnapshot.documents.last
				isLoading = true
				await fetchPosts(querySnapshots: firstSnapshot)
			} catch {
				print("posts paging fetch error \(error.localizedDescription)")
			}
		}
		print(time)
	}
	
	@MainActor
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
	
	@MainActor
	func fetchPosts(querySnapshots: QuerySnapshot) async {
		var tasks: [Task<(Int, Post)?, Error>] = []
		let postRef = db.collection("posts")
		
		for (index, document) in querySnapshots.documents.enumerated() {
			// 각 Task에 문서의 인덱스를 포함시킨다
			let task = Task<(Int, Post)?, Error> {
				let postID = document.documentID
				let postField = try document.data(as: PostField.self)
				
				let postDrinkTagRef = postRef.document(postID).collection("drinkTags")
				let drinkTagSnapshot = try await postDrinkTagRef.getDocuments()
				var drinkTags = [DrinkTag]()
				for drinkTag in drinkTagSnapshot.documents {
					let drinkTagID = drinkTag.documentID
					let rating = drinkTag.data()["rating"] as! Double
					if let drinkTagDocument = try await postDrinkTagRef.document(drinkTagID).collection("drink").getDocuments().documents.first {
						let drinkTagField = try drinkTagDocument.data(as: FBDrink.self)
						drinkTags.append(DrinkTag(drink: drinkTagField, rating: rating))
					}
				}
				
				if let firstImageID = postField.imagesID.first {
					await fetchImage(folderType: .postThumbnail, postID: postID, imageID: firstImageID)
				}

				if let userDocument = try await postRef.document(postID).collection("user").getDocuments().documents.first {
					let userField = try userDocument.data(as: UserField.self)
					await fetchImage(folderType: .user, imageID: userField.userID ?? "")
					return (index, Post(userField: userField, drinkTags: drinkTags, postField: postField))
				}
				return nil
			}
			tasks.append(task)
		}

		// 결과를 비동기적으로 수집
		var results: [(Int, Post)] = []
		for task in tasks {
			do {
				if let result = try await task.value {
					results.append(result)
				}
			} catch {
				print(error.localizedDescription)
			}
		}

		// 원본 문서의 인덱스를 기준으로 결과를 정렬
		results.sort { $0.0 < $1.0 }

		// 인덱스를 제거하고 최종 결과를 추출
		let posts = results.map { $1 }
		self.posts.append(contentsOf: posts)
	}
	
	@MainActor
	func fetchPostDrinkTags(postID: String) async {
		let postRef = db.collection("posts")
		let postDrinkTagRef = postRef.document(postID).collection("drinkTags")
		do {
			let drinkTagSnapshot = try await postDrinkTagRef.getDocuments()
			var drinkTags = [DrinkTag]()
			for drinkTag in drinkTagSnapshot.documents {
				let drinkTagID = drinkTag.documentID
				let rating = drinkTag.data()["rating"] as! Double
				if let drinkTagDocument = try await postDrinkTagRef.document(drinkTagID).collection("drink").getDocuments().documents.first {
					let drinkTagField = try drinkTagDocument.data(as: FBDrink.self)
					drinkTags.append(DrinkTag(drink: drinkTagField, rating: rating))
				}
			}
			for index in self.posts.indices {
				if posts[index].postField.postID == postID {
					posts[index].drinkTags = drinkTags
					break
				}
			}
		} catch {
			print("post fetch error \(error.localizedDescription)")
		}
	}
	
	@MainActor
	func fetchImage(folderType: FireStorageImageFolderType, postID: String? = nil , imageID: String) async {
		let storageRef = Storage.storage().reference().child("\(folderType.description)/\(imageID).jpg")
		storageRef.getData(maxSize: (1 * 1024 * 1024)) { data, error in
			if let data = data, let uiImage = UIImage(data: data) {
				switch folderType {
				case .fcm:
					return
				case .drink:
					return
				case .post:
					if let postID = postID {
						if self.postImages[postID] == nil { 
							self.postImages[postID] = []
						}
						self.postImages[postID]?.append((imageID, uiImage))
					}
				case .postThumbnail:
					if let postID = postID {
						self.postThumbnailImages[postID] = uiImage
					}
				case .user:
					self.postUserImages[imageID] = uiImage
				}
			} else {
				print("\(folderType) fetch image error \(String(describing: error?.localizedDescription))")
			}
		}
	}
}

// MARK: Update
extension PostsViewModel {
	func postLikedUpdate(likeType: LikedActionType, postID: String) async {
		do {
			let postDocument = db.collection("posts").document(postID)
			let postField = try await postDocument.getDocument().data(as: PostField.self)
			switch likeType {
			case .plus:
				try await postDocument.updateData(["likedCount": (postField.likedCount + 1)])
			case .minus:
				try await postDocument.updateData(["likedCount": (postField.likedCount - 1)])
			}
			
		} catch {
			print("post update error \(error.localizedDescription)")
		}
	}
}

// MARK: Delete
extension PostsViewModel {
	// post delete 과정에서 연관된 데이터 삭제
	func postDelete(userID: String, postID: String) async {
//		let postRef = db.collection("posts")
		let userRef = db.collection("users")
		await usersCollectionPostDelete(userRef: userRef, userID: userID, postID: postID)
//		await postsCollectionPostDelete(postRef: postRef, postID: postID)
	}
	
	func postsCollectionPostDelete(postRef: CollectionReference, postID: String) async {
		do {
			try await postRef.document(postID).delete()
		} catch {
			print("postsCollectionPostDelete error \(error.localizedDescription)")
		}
	}
	
	func usersCollectionPostDelete(userRef: CollectionReference, userID: String, postID: String) async {
		do {
			try await userRef.document(userID).collection("posts").document(postID).delete()
		} catch {
			print("usersCollectionPostDelete error \(error.localizedDescription)")
		}
	}
	
	// post delete 과정에서 연관된 collection data 업데이트
	func drinksCollectionUpdate() async {
		
	}
	
	// post의 tagDrinks인 root drinks collection taggedPost에서 postID 있으면 제거 후 업데이트
	func postTaggedDrinkRootCollectionUpdate(drinkRef: CollectionReference, drinkTagsID: [String], postID: String) async {
		do {
			for drinkID in drinkTagsID {
				var taggedPostsID = try await drinkRef.document(drinkID).getDocument().data()?["taggedPostID"] as! [String]
				taggedPostsID.removeAll(where: { $0 == postID })
				try await drinkRef.document(drinkID).updateData(["taggedPostID": taggedPostsID])
			}
		} catch {
			print("postTaggedDataUpdate error \(error.localizedDescription)")
		}
	}
	
	// 전체 posts collection sub collection인 drink 업데이트
	func allPostsSubCollectionDrinkUpdate(postRef: CollectionReference, postID: String) async {
		do {
			let postsDocument = try await postRef.getDocuments()
			for postDocument in postsDocument.documents {
				let postDocumentID = postDocument.documentID
				let drinkTagsDocument = try await postDocument.reference.collection("drinkTags").getDocuments()
				
				for drinkTagDocument in drinkTagsDocument.documents {
					let drinkTagID = drinkTagDocument.documentID
					var taggedPostsID = try await drinkTagDocument
						.reference.collection("drink")
						.document(drinkTagID)
						.getDocument()
						.data()?["taggedPostID"] as! [String]
					
					taggedPostsID.removeAll(where: { $0 == postID })
					
					try await postRef.document(postDocumentID)
						.collection("drinkTags")
						.document(drinkTagID)
						.collection("drink")
						.document(drinkTagID)
						.updateData(["taggedPostID": taggedPostsID])
				}
			}
		} catch {
			print("allPostsSubCollectionDrinkUpdate error \(error.localizedDescription)")
		}
	}
	
	// 전체 유저의 likedPosts에서 삭제되는 postId 삭제 후 업데이트
	func allUsersliekdPostsUpdate() {
		
	}
}

////
////  ExSearchPostViewModel.swift
////  JUDA
////
////  Created by Minjae Kim on 2/26/24.
////
//
//import Foundation
//import FirebaseFirestore
//import FirebaseStorage
//
//@MainActor
//class ExSearchPostsViewModel: ObservableObject {
//	// 파이어베이스 연결
//	private let db = Firestore.firestore()
//	// 게시글 신고 객체
//	// 전체 게시글 객체 배열
//	@Published var posts = [Post]()
//	// 이름으로 검색된 게시글 객체 배열
//	@Published var searchPostsByUserName = [Post]()
//	// 술 태그로 검색된 게시글 객체 배열
//	@Published var searchPostsByDrinkTag = [Post]()
//	// 음식 태그로 검색된 게시글 객체 배열
//	@Published var searchPostsByFoodTag = [Post]()
//	// 전체 포스트에 사용되는 이미지를 갖는 튜플 형태의 배열을 갖고있는 딕셔너리 [포스트ID: [URL]]
//	@Published var postImagesURL: [String: [URL]] = [:]
//	// 전체 포스트의 썸네일 이미지로 사용되는 딕셔너리 [포스트ID: URL]
//	@Published var postThumbnailImagesURL: [String: URL] = [:]
//	// 전체 포스트에 사용되는 작성자의 이미지를 갖는 딕셔너리 [포스트ID: 이미지]
//	@Published var postUserImages: [String: URL] = [:]
//	// 게시글 정렬용 세그먼트 인덱스
//	@Published var selectedSegmentIndex = 0
//	// 게시글 불러오기 작업이 진행중인지 나타내는 상태 프로퍼티
//	@Published var isLoading = false
//	// 게시글 검색 텍스트
//	@Published var postSearchText = ""
//	//
//	@Published var searchTagType: SearchTagType = .userName
//	@Published var foodTag: String?
//}
//
//// MARK: post data fetch
//extension ExSearchPostsViewModel {
//	// 전체 게시글 패치
//	@MainActor
//	func fetchPosts() async {
//		var tasks: [Task<(Int, Post)?, Error>] = []
//		let postRef = db.collection("posts")
//		do {
//			let postSnapshots = try await postRef.getDocuments()
//			
//			for (index, document) in postSnapshots.documents.enumerated() {
//				// 각 Task에 문서의 인덱스를 포함시킨다
//				let task = Task<(Int, Post)?, Error> {
//					let postID = document.documentID
//					let postField = try document.data(as: PostField.self)
//					if self.postImagesURL[postID] == nil {
//						self.postImagesURL[postID] = []
//					}
//					for imageURL in postField.imagesURL {
//						self.postImagesURL[postID]?.append(imageURL)
//					}
//					
//					let postDrinkTagRef = postRef.document(postID).collection("drinkTags")
//					let drinkTagSnapshot = try await postDrinkTagRef.getDocuments()
//					var drinkTags = [DrinkTag]()
//					for drinkTag in drinkTagSnapshot.documents {
//						let drinkTagID = drinkTag.documentID
//						let rating = drinkTag.data()["rating"] as! Double
//						if let drinkTagDocument = try await postDrinkTagRef.document(drinkTagID).collection("drink").getDocuments().documents.first {
//							let drinkTagField = try drinkTagDocument.data(as: FBDrink.self)
//							drinkTags.append(DrinkTag(drink: drinkTagField, rating: rating))
//						}
//					}
//					
//					//				if let firstImageID = postField.imagesID.first {
//					//					await fetchImage(folderType: .postThumbnail, postID: postID, imageID: firstImageID)
//					//				}
//					
//					if let thumbnailImageURL = postField.imagesURL.first {
//						self.postThumbnailImagesURL[postID] = thumbnailImageURL
//					}
//					
//					if let userDocument = try await postRef.document(postID).collection("user").getDocuments().documents.first {
//						let userField = try userDocument.data(as: UserField.self)
//						await userFetchImage(userID: userField.userID ?? "defaultprofileimage")
//						return (index, Post(userField: userField, drinkTags: drinkTags, postField: postField))
//					}
//					return nil
//				}
//				tasks.append(task)
//			}
//		} catch {
//			print(error.localizedDescription)
//		}
//
//		// 결과를 비동기적으로 수집
//		var results: [(Int, Post)] = []
//		for task in tasks {
//			do {
//				if let result = try await task.value {
//					results.append(result)
//				}
//			} catch {
//				print(error.localizedDescription)
//			}
//		}
//
//		// 원본 문서의 인덱스를 기준으로 결과를 정렬
//		results.sort { $0.0 < $1.0 }
//
//		// 인덱스를 제거하고 최종 결과를 추출
//		let posts = results.map { $1 }
//		self.posts = posts
//		
//		self.isLoading = false
//	}
//	
//	@MainActor
//    func userFetchImage(userID: String) async {
//        let storageRef = Storage.storage().reference().child("userImages/\(userID)")
//        storageRef.downloadURL() { url, error in
//            if let error = error {
//                print("Error - fetchImageUrl: \(error.localizedDescription)")
//            } else {
//                self.postUserImages[userID] = url
//            }
//        }
//    }
//}
//
//// MARK: fetch data filtering / sorting
//extension ExSearchPostsViewModel {
//	func postSearch(_ keyword: String) async {
//		// 작업을 병렬로 처리
//		// 배열 안의 값에 키워드가 포함되어 있는 경우 fliter 고차함수를 사용하여 각각의 검색 타입(이름, 술 태그, 음식 태그)에 맞게 필터링
//		await withTaskGroup(of: Void.self) { group in
//				group.addTask {
//					let filteredPostsByUserName = await self.filterPostsBy(keyword: keyword, filterClosure: self.isKeywordInUserName)
//					await self.updateSearchResults(for: .userName, with: filteredPostsByUserName)
//				}
//				group.addTask {
//					let filteredPostsByDrinkTag = await self.filterPostsBy(keyword: keyword, filterClosure: self.isKeywordInDrinkTags)
//					await self.updateSearchResults(for: .drinkTag, with: filteredPostsByDrinkTag)
//				}
//				group.addTask {
//					let filteredPostsByFoodTag = await self.filterPostsBy(keyword: keyword, filterClosure: self.isKeywordInFoodTags)
//					await self.updateSearchResults(for: .foodTag, with: filteredPostsByFoodTag)
//				}
//			}
//	}
//	
//	private func updateSearchResults(for category: SearchTagType, with posts: [Post]) {
//		switch category {
//		case .userName:
//			self.searchPostsByUserName = posts
//		case .drinkTag:
//			self.searchPostsByDrinkTag = posts
//		case .foodTag:
//			self.searchPostsByFoodTag = posts
//		}
//	}
//
//	private func filterPostsBy(keyword: String, filterClosure: @escaping (Post, String) async -> Bool) async -> [Post] {
//		var filteredPosts: [Post] = []
//		for post in posts {
//			if await filterClosure(post, keyword) {
//				filteredPosts.append(post)
//			}
//		}
//		return filteredPosts
//	}
//
//	private func isKeywordInUserName(post: Post, keyword: String) -> Bool {
//		return post.userField.name.localizedCaseInsensitiveContains(keyword)
//	}
//
//	private func isKeywordInDrinkTags(post: Post, keyword: String) -> Bool {
//		guard let drinkTags = post.drinkTags else { return false }
//		return drinkTags.contains { $0.drink.name.localizedCaseInsensitiveContains(keyword) }
//	}
//
//	private func isKeywordInFoodTags(post: Post, keyword: String) -> Bool {
//		return post.postField.foodTags.contains { $0.localizedCaseInsensitiveContains(keyword) }
//	}
//	
//	// 포스트를 검색 태그 타입별로 최신순 / 인기순 정렬
//	func postSortBySearchTagType(searchTagType: SearchTagType, postSortType: PostSortType) async {
//		let postsToSort: [Post]
//		switch searchTagType {
//		case .userName:
//			postsToSort = searchPostsByUserName
//		case .drinkTag:
//			postsToSort = searchPostsByDrinkTag
//		case .foodTag:
//			postsToSort = searchPostsByFoodTag
//		}
//
//		let sortedPosts = await sortPosts(posts: postsToSort, by: postSortType)
//		switch searchTagType {
//		case .userName:
//			searchPostsByUserName = sortedPosts
//		case .drinkTag:
//			searchPostsByDrinkTag = sortedPosts
//		case .foodTag:
//			searchPostsByFoodTag = sortedPosts
//		}
//	}
//
//	private func sortPosts(posts: [Post], by sortType: PostSortType) async -> [Post] {
//		switch sortType {
//		case .popularity:
//			return posts.sorted(by: { $0.postField.likedCount > $1.postField.likedCount })
//		case .mostRecent:
//			return posts.sorted(by: { $0.postField.postedTimeStamp > $1.postField.postedTimeStamp })
//		}
//	}
//}

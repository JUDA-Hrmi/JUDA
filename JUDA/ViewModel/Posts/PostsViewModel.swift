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
	// 게시글 신고 객체
	@Published var report: Report?
	// 마지막 포스트 확인용(페이징)
	@Published var lastQuerydocumentSnapshot: QueryDocumentSnapshot?
	// 전체 포스트에 사용되는 이미지를 갖는 튜플 형태의 배열을 갖고있는 딕셔너리 [포스트ID: [URL]]
	@Published var postImagesURL: [String: [URL]] = [:]
	// 전체 포스트의 썸네일 이미지로 사용되는 딕셔너리 [포스트ID: URL]
	@Published var postThumbnailImagesURL: [String: URL] = [:]
	// 전체 포스트에 사용되는 작성자의 이미지를 갖는 딕셔너리 [포스트ID: 이미지]
	@Published var postUserImages: [String: UIImage] = [:]
	// 게시글 정렬용 세그먼트 인덱스
	@Published var selectedSegmentIndex = 0
	// 게시글 정렬 타입
	@Published var postSortType = PostSortType.allCases
	// 게시글 불러오기/업로드/삭제/수정 작업이 진행중인지 나타내는 상태 프로퍼티
	@Published var isLoading = false
	// 게시글이 수정이 되었는지 유무 판단하는 상태 프로퍼티
	@Published var isUpdate = false
	// 태그된 게시글 리스트 ( DrinkDetail 에서 이동할 때 사용 )
	@Published var drinkTaggedPosts = [Post]()
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
				if self.postImagesURL[postID] == nil {
					self.postImagesURL[postID] = []
				}
				for imageURL in postField.imagesURL {
					self.postImagesURL[postID]?.append(imageURL)
				}
				
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
				
				if let thumbnailImageURL = postField.imagesURL.first {
					self.postThumbnailImagesURL[postID] = thumbnailImageURL
				}

				if let userDocument = try await postRef.document(postID).collection("user").getDocuments().documents.first {
					let userField = try userDocument.data(as: UserField.self)
					await userFetchImage(imageID: userField.userID ?? "defaultprofileimage")
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
		
		self.isLoading = false
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
    func userFetchImage(imageID: String) async {
        let storageRef = Storage.storage().reference().child("userImages/\(imageID)")
        storageRef.getData(maxSize: (1 * 1024 * 1024)) { data, error in
            if let data = data, let uiImage = UIImage(data: data) {
                self.postUserImages[imageID] = uiImage
            } else {
                print("fetch user image error \(String(describing: error?.localizedDescription))")
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
		let postRef = db.collection("posts")
		let userRef = db.collection("users")
		await postsCollectionPostDelete(postRef: postRef, postID: postID)
		await usersCollectionPostDelete(userRef: userRef, userID: userID, postID: postID)
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
	
	func postImagesURLDelete(postRef: CollectionReference, postID: String) async {
		do {
			// TODO: 이미지 storage에서 삭제
			let storageRef = Storage.storage().reference()
			let imagesURL = try await postRef.document(postID).getDocument().data(as: PostField.self).imagesURL
			
			for imageURL in imagesURL {
				if let fileName = getImageFileName(imageURL: imageURL) {
					let imageRef = storageRef.child("postImages/\(fileName)")
					try await imageRef.delete()
				} else {
					print("postImagesURLDelete() -> error dont't get fileName")
				}
			}
		} catch {
			print("postImagesURLDelete() -> error \(error.localizedDescription)")
		}
	}
	
	// fileName 추추
	func getImageFileName(imageURL: URL) -> String? {
		let path = imageURL.path
		// '%' 인코딩된 문자 디코딩
		guard let decodedPath = path.removingPercentEncoding else { return nil }
		// '/'를 기준으로 문자열 분리 후 마지막 요소 추출 후 리턴
		return decodedPath.components(separatedBy: "/").last
	}
}

// MARK: - 태그 된 인기 게시물 / 태그 된 게시물 Fetch ( Drink Detail View )
extension PostsViewModel {
    // Drink Detail View 에서 사용 : PostField 를 받아서 Post 로 반환
    @MainActor
    private func fetchTaggedPosts(postFields: [PostField]) async -> [Post] {
        let postRef = db.collection("posts")
        var tasks: [Task<(Int, Post)?, Error>] = []

        for (index, postField) in postFields.enumerated() {
            let postID = postField.postID ?? ""
            let task = Task<(Int, Post)?, Error> {
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
                if let userDocument = try await postRef.document(postID).collection("user").getDocuments().documents.first {
                    let userField = try userDocument.data(as: UserField.self)
                    await userFetchImage(imageID: userField.userID ?? "")
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
        return results.map { $1 }
    }
    
    // Drink Detail View 에서 사용 : 태그된 인기 게시물 최대 3개만 [Post] 반환
    @MainActor
    func getTopTrendingPosts(taggedPostID: [String]) async -> [Post] {
        let postRef = db.collection("posts")
        var result = [PostField]()
        for postID in taggedPostID {
            do {
                let document = try await postRef.document(postID).getDocument()
                let postField = try document.data(as: PostField.self)
                result.append(postField)
            } catch {
                print("get Top Trending Posts Error")
            }
        }
        result.sort { $0.likedCount > $1.likedCount }
        result = Array(result.prefix(3))
        
        return await fetchTaggedPosts(postFields: result)
    }
    
    // Drink Detail View 에서 사용 : 태그된 게시물 [Post] 반환
    @MainActor
    func getTaggedPosts(taggedPostID: [String], sortType: PostSortType) async {
        let postRef = db.collection("posts")
        var result = [PostField]()
        for postID in taggedPostID {
            do {
                let document = try await postRef.document(postID).getDocument()
                let postField = try document.data(as: PostField.self)
                self.isLoading = true
                result.append(postField)
            } catch {
                print("get Tagged Posts Error")
            }
        }
        if sortType == .popularity {
            result.sort { $0.likedCount > $1.likedCount} // 인기순
        } else {
            result.sort { $0.postedTimeStamp > $1.postedTimeStamp} // 최신순
        }
        self.drinkTaggedPosts = await fetchTaggedPosts(postFields: result)
    }
}

// MARK: Post Report
extension PostsViewModel {
	func postReportUpload() {
		guard let report = report else { return }
		do {
			let reportDocumentPath = UUID().uuidString
			
			let reportRef = db.collection("reports")
			try reportRef.document(reportDocumentPath).setData(from: report)
			
		} catch {
			print("Report upload Error :: \(error.localizedDescription)")
		}
	}
}

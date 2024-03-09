//
//  PostService.swift
//  JUDA
//
//  Created by Minjae Kim on 3/8/24.
//

import SwiftUI
import FirebaseFirestore

// MARK: - 술상 정렬 enum
enum PostSortType: String, CaseIterable {
    case popularity = "인기"
    case mostRecent = "최신"
    // 리스트
    static let list: [PostSortType] = PostSortType.allCases
}

// MARK: - 술상 검색 enum
enum SearchTagType: String, CaseIterable {
    case userName = "작성자"
    case drinkTag = "술 태그"
    case foodTag = "음식 태그"
    // 리스트
    static let list: [SearchTagType] = SearchTagType.allCases
}

// MARK: - 좋아요 + / -
enum LikedActionType {
    case plus, minus
}

// MARK: - Post View Model ( 술상 )
@MainActor
final class PostViewModel: ObservableObject {
	// 파이어베이스 연결
    private let db = Firestore.firestore()
	private let postCollection = "posts"
	private let firestorePostService = FirestorePostService()
    private let firestoreDrinkService = FirestoreDrinkService()
	private let firestoreReportService = FirestoreReportService()
	
	// 게시글 객체 배열
	@Published var posts = [Post]()
    // 이름으로 검색된 게시글 객체 배열
    @Published var searchPostsByUserName = [Post]()
    // 술 태그로 검색된 게시글 객체 배열
    @Published var searchPostsByDrinkTag = [Post]()
    // 음식 태그로 검색된 게시글 객체 배열
    @Published var searchPostsByFoodTag = [Post]()
	// 마지막 포스트 확인용(페이징)
	@Published var lastQuerydocumentSnapshot: QueryDocumentSnapshot?
	// 게시글 불러오기 또는 삭제 작업이 진행중인지 나타내는 상태 프로퍼티
	@Published var isLoading = false
}

// MARK: - Fetch
extension PostViewModel {
    // 술상 정렬 타입 ( 인기순 / 최신순 )
	func getPostSortType(postSortType: PostSortType) -> Query {
		let postRef = db.collection(postCollection)
		
		switch postSortType {
		case .popularity:
			return postRef.order(by: "likedCount", descending: true)
		case .mostRecent:
			return postRef.order(by: "postedTimeStamp", descending: true)
		}
	}
	
    // 술상 첫 20개 불러오기 - 페이지네이션
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
	
    // 술상 다음 20개 불러오기 - 페이지네이션
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
	
    // Post 데이터 받아오기
	private func fetchPosts(querySnapshots: QuerySnapshot) async {
		var tasks: [Task<(Int, Post)?, Error>] = []
		let postRef = db.collection(postCollection)
		
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

// MARK: - Delete
extension PostViewModel {
    // post 삭제
    func deletePost(postID: String) async {
        do {
            try await firestorePostService.deletePostDocument(postID: postID)
        } catch {
            print("error :: deletePost", error.localizedDescription)
        }
    }
}

// MARK: - Update
extension PostViewModel {
    // post 수정
    func editPost(postID: String, content: String?, foodTags: [String]?) async {
        do {
            let collectionRef = db.collection(postCollection)
            if let content = content {
                try await firestorePostService.updatePostField(ref: collectionRef,
                                                               postID: postID,
                                                               data: ["content": content])
            }
            if let foodTags = foodTags {
                try await firestorePostService.updatePostField(ref: collectionRef,
                                                               postID: postID,
                                                               data: ["foodTags": foodTags])
            }
        } catch {
            print("error :: editPost", error.localizedDescription)
        }
    }
}

// MARK: - Search
extension PostViewModel {
    // 게시글 검색해서 데이터 받아오기
    func getSearchedPosts(from keyword: String) async {
        self.isLoading = true
        do {
            let collectionRef = db.collection(postCollection)
            let postSnapshot = try await collectionRef.getDocuments()
            for postDocument in postSnapshot.documents {
                let postFieldData = try postDocument.data(as: PostField.self)
                let postID = postDocument.documentID
                let documentRef = collectionRef.document(postID)
                //
                await withTaskGroup(of: Void.self) { group in
                    group.addTask {
                        await self.updateSearchResults(for: .userName, postField: postFieldData,
                                                       keyword: keyword, documentRef: documentRef)
                    }
                    group.addTask {
                        await self.updateSearchResults(for: .drinkTag, postField: postFieldData,
                                                       keyword: keyword, documentRef: documentRef)
                    }
                    group.addTask {
                        await self.updateSearchResults(for: .foodTag, postField: postFieldData,
                                                       keyword: keyword, documentRef: documentRef)
                    }
                }
            }
        } catch {
            print("error :: getSearchedPosts", error.localizedDescription)
        }
        self.isLoading = false
    }
    
    // searchPostsBy... 배열에 값을 채워주는 메서드
    private func updateSearchResults(for category: SearchTagType, postField: PostField, keyword: String, documentRef: DocumentReference) async {
        do {
            switch category {
            case .userName:
                if isKeywordInUserName(postField: postField, keyword: keyword) {
                    let postData = try await firestorePostService.fetchPostDocument(document: documentRef)
                    self.searchPostsByUserName.append(postData)
                }
            case .drinkTag:
                if isKeywordInDrinkTags(postField: postField, keyword: keyword) {
                    let postData = try await firestorePostService.fetchPostDocument(document: documentRef)
                    self.searchPostsByDrinkTag.append(postData)
                }
            case .foodTag:
                if isKeywordInFoodTags(postField: postField, keyword: keyword) {
                    let postData = try await firestorePostService.fetchPostDocument(document: documentRef)
                    self.searchPostsByFoodTag.append(postData)
                }
            }
        } catch {
            print("error :: updateSearchResults", error.localizedDescription)
        }
    }
    
    // 키워드가 post 를 작성한 유저의 이름에 포함되는지
    private func isKeywordInUserName(postField: PostField, keyword: String) -> Bool {
        return postField.user.userName.localizedCaseInsensitiveContains(keyword)
    }

    // 키워드가 post 에 태그된 술의 이름에 포함되는지
    private func isKeywordInDrinkTags(postField: PostField, keyword: String) -> Bool {
        return postField.drinkTags.contains {
            $0.drinkName.localizedCaseInsensitiveContains(keyword)
        }
    }

    // 키워드가 post 에 태그된 음식의 이름에 포함되는지
    private func isKeywordInFoodTags(postField: PostField, keyword: String) -> Bool {
        return postField.foodTags.contains {
            $0.localizedCaseInsensitiveContains(keyword)
        }
    }
    
}

// MARK: - Report Upload
extension PostViewModel {
    // 신고 등록
    func uploadPostReport(report: Report) async {
        do {
            try await firestoreReportService.uploadReport(report: report)
        } catch {
            print("error :: uploadPostReport", error.localizedDescription)
        }
    }
}

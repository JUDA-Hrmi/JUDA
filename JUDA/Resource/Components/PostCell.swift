//
//  PostCell.swift
//  JUDA
//
//  Created by Minjae Kim on 1/25/24.
//

import SwiftUI
import Kingfisher

// MARK: - 술상 그리드 셀
struct PostCell: View {
	@EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var postsViewModel: PostsViewModel
    @EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
	@EnvironmentObject private var likedViewModel: LikedViewModel

	@State private var isLike: Bool = false
	@State private var likeCount: Int = 0
	
	let usedTo: WhereUsedPostGridContent
	let post: Post
	private let debouncer = Debouncer(delay: 0.5)
    
    private var profileImageURL: URL? {
        let userID = post.userField.userID ?? ""
        switch usedTo {
        case .postSearch:
            return searchPostsViewModel.postUserImages[userID]
        case .liked:
            return likedViewModel.postUserImages[userID]
        case .myPage:
            return myPageViewModel.postUserImages[userID]
        case .main:
            return mainViewModel.postUserImages[userID]
        default: // post 그 외
            return postsViewModel.postUserImages[userID]
        }
    }
    
	var body: some View {
		// VStack에 기본적인 spacing이 들어가기 때문에 0으로 설정
		VStack(spacing: 0) {
			ZStack(alignment: .topTrailing) {
				// 게시글 사진리스트의 첫 번째 사진
                KFImage.url(post.postField.imagesURL.first)
                    .placeholder {
                        CircularLoaderView(size: 20)
                            .frame(width: 170, height: 170)
                            .clipped()
                    }
                    .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
                    .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
                    .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
                    .fade(duration: 0.2) // 이미지 부드럽게 띄우기
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 170, height: 170)
                    .clipped()
				// 게시글 사진이 2장 이상일 경우, 상자 아이콘이 사진의 trailing 상단에 보여짐
				if post.postField.imagesURL.count >= 2 {
					Image(systemName: "square.on.square.fill")
						.frame(width: 18, height: 18)
						.foregroundStyle(.white)
						.padding([.top, .trailing], 10)
				}
			}
			HStack {
                HStack {
                    // 사용자의 프로필 사진
                    if let profileImageURL = profileImageURL {
                        PostCellUserProfileKFImage(url: profileImageURL)
                    } else {
						Image("defaultprofileimage")
							.resizable()
							.frame(width: 20, height: 20)
							.clipShape(.circle)
					}
					// 사용자의 닉네임
					Text(post.userField.name)
						.lineLimit(1)
						.font(.regular14)
						.foregroundStyle(.mainBlack)
				}
				.padding(.leading, 5)
				
				Spacer()
				
				// 좋아요 버튼
				HStack {
					// 좋아요를 등록 -> 빨간색이 채워진 하트
					// 좋아요를 해제 -> 테두리가 회색인 하트
					Button {
						// TODO: 로그인 안 되어 있을 때, 로그인 페이지 넘어가기
						if authService.signInStatus {
							debouncer.call {
								switch usedTo {
								case .post:
									postLikeButtonAction()
								case .postSearch:
									postSearchLikeButtonAction()
								case .postFoodTag:
									postSearchLikeButtonAction()
								case .drinkDetail:
									return
								case .liked:
									return
								case .myPage:
									return
                                default:
                                    return
								}
							}
						}
					} label: {
						Image(systemName: isLike ? "heart.fill" : "heart")
							.foregroundStyle(isLike ? .mainAccent01 : .gray01)
					}
					Text(Formatter.formattedPostLikesCount(likeCount))
						.foregroundStyle(.gray01)
				}
				.font(.regular14)
				.padding(.trailing, 5)
//				.onTapGesture {
//					// TODO: 로그인 안 되어 있을 때, 로그인 페이지 넘어가기
//					if authService.signInStatus {
//						likeButtonAction()
//					}
//				}
			}
			.frame(height: 35)
		}
		.frame(maxWidth: 170, maxHeight: 200)
		.task {
			if authService.signInStatus {
				self.isLike = authService.likedPosts.contains(where: { $0 == post.postField.postID })
			}
			print(post.postField.likedCount)
			self.likeCount = post.postField.likedCount
		}
	}
	
	// 좋아요 버튼 액션 메서드
	private func postLikeButtonAction() {
		// 좋아요 등록 -> 좋아요 수에 + 1
		// 좋아요 해제 -> 좋아요 수에 - 1
		guard let postID = post.postField.postID else {
			print("PostCell :: likeButtonAction() error -> dot't get postID")
			return
		}
		if isLike {
			likeCount -= 1
			authService.likedPosts.removeAll(where: { $0 == postID })
			authService.userLikedPostsUpdate()
			
			if let index = postsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
				postsViewModel.posts[index].postField.likedCount -= 1
			}
			if let index = searchPostsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
				searchPostsViewModel.posts[index].postField.likedCount -= 1
			}
			Task {
				await postsViewModel.postLikedUpdate(likeType: .minus, postID: postID, userID: post.userField.userID ?? "")
			}
		} else {
			likeCount += 1
			authService.likedPosts.append(postID)
			authService.userLikedPostsUpdate()
			
			if let index = postsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
				postsViewModel.posts[index].postField.likedCount += 1
			}
			if let index = searchPostsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
				searchPostsViewModel.posts[index].postField.likedCount += 1
			}
			Task {
				await postsViewModel.postLikedUpdate(likeType: .plus, postID: postID, userID: post.userField.userID ?? "")
			}
		}
		isLike.toggle()
	}
	
	private func postSearchLikeButtonAction() {
		// 좋아요 등록 -> 좋아요 수에 + 1
		// 좋아요 해제 -> 좋아요 수에 - 1
		guard let postID = post.postField.postID else {
			print("PostCell :: likeButtonAction() error -> dot't get postID")
			return
		}
		Task {
			if isLike {
				likeCount -= 1
				authService.likedPosts.removeAll(where: { $0 == postID })
				authService.userLikedPostsUpdate()
				
				if let index = searchPostsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
					searchPostsViewModel.posts[index].postField.likedCount -= 1
				}
				
				await withTaskGroup(of: Void.self) { group in
					group.addTask {
						if let index = await searchPostsViewModel.searchPostsByUserName.firstIndex(where: { $0.postField.postID == postID }) {
							await searchPostslikedUpdateWithTag(searchTagType: .userName, likedType: .minus, index: index)
						}
					}
					group.addTask {
						if let index = await searchPostsViewModel.searchPostsByDrinkTag.firstIndex(where: { $0.postField.postID == postID }) {
							await searchPostslikedUpdateWithTag(searchTagType: .drinkTag, likedType: .minus, index: index)
						}
					}
					group.addTask {
						if let index = await searchPostsViewModel.searchPostsByFoodTag.firstIndex(where: { $0.postField.postID == postID }) {
							await searchPostslikedUpdateWithTag(searchTagType: .foodTag, likedType: .minus, index: index)
						}
					}
				}
				
				if let index = postsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
					postsViewModel.posts[index].postField.likedCount -= 1
				}
				
				await postsViewModel.postLikedUpdate(likeType: .minus, postID: postID, userID: post.userField.userID ?? "")
			} else {
				likeCount += 1
				authService.likedPosts.append(postID)
				authService.userLikedPostsUpdate()
				
				if let index = searchPostsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
					searchPostsViewModel.posts[index].postField.likedCount += 1
				}
				await withTaskGroup(of: Void.self) { group in
					group.addTask {
						if let index = await searchPostsViewModel.searchPostsByUserName.firstIndex(where: { $0.postField.postID == postID }) {
							await searchPostslikedUpdateWithTag(searchTagType: .userName, likedType: .plus, index: index)
						}
					}
					group.addTask {
						if let index = await searchPostsViewModel.searchPostsByDrinkTag.firstIndex(where: { $0.postField.postID == postID }) {
							await searchPostslikedUpdateWithTag(searchTagType: .drinkTag, likedType: .plus, index: index)
						}
					}
					group.addTask {
						if let index = await searchPostsViewModel.searchPostsByFoodTag.firstIndex(where: { $0.postField.postID == postID }) {
							await searchPostslikedUpdateWithTag(searchTagType: .foodTag, likedType: .plus, index: index)
						}
					}
				}
				if let index = postsViewModel.posts.firstIndex(where: { $0.postField.postID == postID }) {
					postsViewModel.posts[index].postField.likedCount += 1
				}
				await postsViewModel.postLikedUpdate(likeType: .plus, postID: postID, userID: post.userField.userID ?? "")
			}
			isLike.toggle()
		}
	}
	
	private func searchPostslikedUpdateWithTag(searchTagType: SearchTagType, likedType: LikedActionType, index: Int) {
		switch searchTagType {
		case .userName:
			if likedType == .minus {
				searchPostsViewModel.searchPostsByUserName[index].postField.likedCount -= 1
			} else {
				searchPostsViewModel.searchPostsByUserName[index].postField.likedCount += 1
			}
		case .drinkTag:
			if likedType == .minus {
				searchPostsViewModel.searchPostsByDrinkTag[index].postField.likedCount -= 1
			} else {
				searchPostsViewModel.searchPostsByDrinkTag[index].postField.likedCount += 1
			}
		case .foodTag:
			if likedType == .minus {
				searchPostsViewModel.searchPostsByFoodTag[index].postField.likedCount -= 1
			} else {
				searchPostsViewModel.searchPostsByFoodTag[index].postField.likedCount += 1
			}
		}
	}
}

// MARK: - PostCell 의 이미지 프로필에서 사용하는 KFImage
struct PostCellUserProfileKFImage: View {
    let url: URL
    
    var body: some View {
        KFImage.url(url)
            .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
            .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
            .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
            .fade(duration: 0.2) // 이미지 부드럽게 띄우기
            .resizable()
            .frame(width: 20, height: 20)
            .clipShape(.circle)
    }
}

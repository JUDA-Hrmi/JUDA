//
//  PostInfo.swift
//  JUDA
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

// MARK: - 술상 디테일에서 상단에 유저 + 글 작성 시간 + 좋아요
struct PostInfo: View {
    @Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var authService: AuthService
	@EnvironmentObject private var postsViewModel: PostsViewModel
	@EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
	@State private var isLike: Bool = false
	@State private var likeCount: Int = 0
	let post: Post
	let usedTo: WhereUsedPostGridContent
	private let debouncer = Debouncer(delay: 0.5)

    var body: some View {
        HStack {
            // 사용자의 프로필
            HStack(alignment: .center, spacing: 10) {
                // 이미지
				if let userID = post.userField.userID,
				   let uiImage = postsViewModel.postUserImages[userID] {
					Image(uiImage: uiImage)
						.resizable()
						.frame(width: 30, height: 30)
						.clipShape(.circle)
				} else {
					Image("defaultprofileimage")
						.resizable()
						.frame(width: 30, height: 30)
						.clipShape(.circle)
				}
                VStack(alignment: .leading) {
                    NavigationLink {
                        // TODO: NavigationLink - value 로 수정
						NavigationProfileView(userType: UserType.otheruser, userName: post.userField.name)
                    } label: {
                        // 사용자의 닉네임
						Text(post.userField.name)
                            .lineLimit(1)
                            .font(.regular18)
                            .foregroundStyle(.mainBlack)
                    }
                    // 게시글 올린 날짜
					let dateString = dateToString(date: post.postField.postedTimeStamp)
					Text(dateString)
                        .font(.regular14)
                        .foregroundStyle(.gray01)
                }
            }
            //
            Spacer()
            // 좋아요 버튼
            HStack(spacing: 4) {
                // 좋아요를 등록 -> 빨간색이 채워진 하트
                // 좋아요를 해제 -> 테두리가 회색인 하트
                Image(systemName: isLike ? "heart.fill" : "heart")
                    .foregroundStyle(isLike ? .mainAccent01 : .gray01)
                // 좋아요 수
                Text(Formatter.formattedPostLikesCount(likeCount))
                    .foregroundStyle(.gray01)
            }
            .font(.regular16)
            .onTapGesture {
				debouncer.call {
//					postLikeButtonAction()
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
					}
				}
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
		.task {
			self.isLike = authService.likedPosts.contains(where: { $0 == post.postField.postID })
			self.likeCount = post.postField.likedCount
		}
    }
    
    // 좋아요 버튼 액션 메서드
    private func postLikeButtonAction() {
        // 좋아요 등록 -> 좋아요 수에 + 1
        // 좋아요 해제 -> 좋아요 수에 - 1
		guard let postID = post.postField.postID else {
			print("PostInfo :: likeButtonAction() error -> dot't get postID")
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
	
	private func dateToString(date: Date) -> String {
		let myFormatter = DateFormatter()
		myFormatter.dateFormat = "yyyy.MM.dd"  // 변환할 형식
		let dateString = myFormatter.string(from: date)
		return dateString
	}
}

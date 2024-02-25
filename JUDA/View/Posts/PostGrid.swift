//
//  PostGrid.swift
//  JUDA
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

// MARK: - 스크롤 뷰 or 뷰 로 보여질 post grid
struct PostGrid: View {
	@EnvironmentObject private var postsViewModel: PostsViewModel
    @State private var scrollAxis: Axis.Set = .vertical
    @State private var vHeight = 0.0
	
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
				PostGridContent()
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollDismissesKeyboard(.immediately)
            .refreshable {
				await postsRefreshable()
            }
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                PostGridContent()
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    PostGridContent()
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable {
					await postsRefreshable()
                }
            }
        }
    }
	private func postsRefreshable() async {
		postsViewModel.posts = []
		postsViewModel.postImages = [:]
		postsViewModel.postThumbnailImages = [:]
		let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
		let query = postsViewModel.getPostSortType(postSortType: postSortType)
		await postsViewModel.firstFetchPost(query: query)
		print(postsViewModel.posts.count)
	}
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 post grid 내용 부분
struct PostGridContent: View {
	@EnvironmentObject private var authService: AuthService
	@EnvironmentObject private var postsViewModel: PostsViewModel
	
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
			ForEach(postsViewModel.posts, id: \.postField.postID) { post in
                NavigationLink {
					PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
								   post: post,
								   postPhotos: postsViewModel.postImages[post.postField.postID ?? ""] ?? [])
                        .modifier(TabBarHidden())
                } label: {
					if postsViewModel.isLoading {
						ShimmerPostCell()
							.onChange(of: postsViewModel.postThumbnailImages) { _ in
								if postsViewModel.postThumbnailImages.count >= 10 {
									postsViewModel.isLoading = false
								}
							}
					} else {
						PostCell(post: post)
							.task {
								if let lastPostID = postsViewModel.posts.last?.postField.postID, post.postField.postID == lastPostID {
									let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
									let query = postsViewModel.getPostSortType(postSortType: postSortType)
									await postsViewModel.nextFetchPost(query: query)
								}
							}
							.border(.blue)
					}
                }
                .buttonStyle(EmptyActionStyle())
				// TODO: 비로그인 상태인 경우 눌렀을 때 로그인뷰로 이동
				.disabled(!authService.signInStatus)
            }
        }
        .padding(.horizontal, 20)
    }
}

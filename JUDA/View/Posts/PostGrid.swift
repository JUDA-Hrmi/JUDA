//
//  PostGrid.swift
//  JUDA
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

// MARK: - 어느 뷰에서 PostGridContent 이 사용되는지 enum
enum WhereUsedPostGridContent {
    case post
    case postSearch
	case postFoodTag
    case drinkDetail
    case liked
    case myPage
    case main
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 post grid
struct PostGrid: View {
	@EnvironmentObject private var postsViewModel: PostsViewModel
	@EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
    
    @State private var scrollAxis: Axis.Set = .vertical
    @State private var vHeight = 0.0
    let usedTo: WhereUsedPostGridContent
	
	let searchTagType: SearchTagType?
    init(usedTo: WhereUsedPostGridContent = .post, searchTagType: SearchTagType?) {
        self.usedTo = usedTo
		self.searchTagType = searchTagType
    }
	
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
				PostGridContent(usedTo: usedTo, searchTagType: searchTagType)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollDismissesKeyboard(.immediately)
            .refreshable {
				await postsRefreshable()
            }
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
				PostGridContent(usedTo: usedTo, searchTagType: searchTagType)
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
					PostGridContent(usedTo: usedTo, searchTagType: searchTagType)
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable {
					await postsRefreshable()
					await searchPostsViewModel.fetchPosts()
                }
            }
        }
    }
	private func postsRefreshable() async {
		postsViewModel.posts = []
		postsViewModel.postImagesURL = [:]
		postsViewModel.postThumbnailImagesURL = [:]
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
	@EnvironmentObject private var myPageViewModel: MyPageViewModel
	@EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
    
    let usedTo: WhereUsedPostGridContent
	let searchTagType: SearchTagType?
    let userType: UserType
    
    init(usedTo: WhereUsedPostGridContent, searchTagType: SearchTagType?, userType: UserType = .user) {
        self.usedTo = usedTo
        self.searchTagType = searchTagType
        self.userType = userType
    }
	
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
            if usedTo == .post {
				if !postsViewModel.isLoading {
					ForEach(postsViewModel.posts, id: \.postField.postID) { post in
						NavigationLink {
							PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
										   post: post,
										   usedTo: usedTo,
										   postPhotosURL: postsViewModel.postImagesURL[post.postField.postID ?? ""] ?? [])
							.modifier(TabBarHidden())
						} label: {
							PostCell(usedTo: .post, post: post)
								.task {
									if let lastPostID = postsViewModel.posts.last?.postField.postID, post.postField.postID == lastPostID {
										let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
										let query = postsViewModel.getPostSortType(postSortType: postSortType)
										await postsViewModel.nextFetchPost(query: query)
									}
								}
						}
						.buttonStyle(EmptyActionStyle())
						// TODO: 비로그인 상태인 경우 눌렀을 때 로그인뷰로 이동
						.disabled(!authService.signInStatus)
					}
				} else {
					ForEach(0..<10) { _ in
						ShimmerPostCell()
					}
				}
                
			} else if usedTo == .postSearch {
				if let searchTagType = searchTagType {
					switch searchTagType {
					case .userName:
						ForEach(searchPostsViewModel.searchPostsByUserName, id: \.postField.postID) { post in
							NavigationLink {
								PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
											   post: post,
											   usedTo: usedTo,
											   postPhotosURL: searchPostsViewModel.postImagesURL[post.postField.postID ?? ""] ?? [])
								.modifier(TabBarHidden())
							} label: {
								PostCell(usedTo: .postSearch, post: post)
							}
							.buttonStyle(EmptyActionStyle())
							// TODO: 비로그인 상태인 경우 눌렀을 때 로그인뷰로 이동
							.disabled(!authService.signInStatus)
						}
					case .drinkTag:
						ForEach(searchPostsViewModel.searchPostsByDrinkTag, id: \.postField.postID) { post in
							NavigationLink {
								PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
											   post: post,
											   usedTo: usedTo,
											   postPhotosURL: searchPostsViewModel.postImagesURL[post.postField.postID ?? ""] ?? [])
								.modifier(TabBarHidden())
							} label: {
								PostCell(usedTo: .postSearch, post: post)
							}
							.buttonStyle(EmptyActionStyle())
							// TODO: 비로그인 상태인 경우 눌렀을 때 로그인뷰로 이동
							.disabled(!authService.signInStatus)
						}
					case .foodTag:
						ForEach(searchPostsViewModel.searchPostsByFoodTag, id: \.postField.postID) { post in
							NavigationLink {
								PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
											   post: post,
											   usedTo: usedTo,
											   postPhotosURL: searchPostsViewModel.postImagesURL[post.postField.postID ?? ""] ?? [])
								.modifier(TabBarHidden())
							} label: {
								PostCell(usedTo: .postSearch, post: post)
							}
							.buttonStyle(EmptyActionStyle())
							// TODO: 비로그인 상태인 경우 눌렀을 때 로그인뷰로 이동
							.disabled(!authService.signInStatus)
						}
					}
				}
			} else if usedTo == .postFoodTag {
				ForEach(searchPostsViewModel.searchPostsByFoodTag, id: \.postField.postID) { post in
					NavigationLink {
						PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
									   post: post,
									   usedTo: usedTo,
									   postPhotosURL: searchPostsViewModel.postImagesURL[post.postField.postID ?? ""] ?? [])
						.modifier(TabBarHidden())
					} label: {
						PostCell(usedTo: .postSearch, post: post)
					}
					.buttonStyle(EmptyActionStyle())
					// TODO: 비로그인 상태인 경우 눌렀을 때 로그인뷰로 이동
					.disabled(!authService.signInStatus)
				}
			} else if usedTo == .drinkDetail {
                if !postsViewModel.isLoading {
                    ForEach(postsViewModel.drinkTaggedPosts, id: \.postField.postID) { post in
                        NavigationLink {
                            PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
                                           post: post,
										   usedTo: usedTo,
										   postPhotosURL: post.postField.imagesURL)
                            .modifier(TabBarHidden())
                        } label: {
							PostCell(usedTo: usedTo, post: post)
                        }
                    }
                } else {
                    ForEach(0..<6) { _ in
                        ShimmerPostCell()
                    }
                }
            } else if usedTo == .myPage {
                if !myPageViewModel.isLoading {
                    if userType == .user {
                        ForEach(myPageViewModel.userPosts, id: \.postField.postID) { post in
                            NavigationLink {
                                PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
                                               post: post,
                                               usedTo: usedTo,
                                               postPhotosURL: post.postField.imagesURL)
                                .modifier(TabBarHidden())
                            } label: {
                                PostCell(usedTo: usedTo, post: post)
                            }
                        }
                    } else {
                        ForEach(myPageViewModel.otherUserPosts, id: \.postField.postID) { post in
                            NavigationLink {
                                PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
                                               post: post,
                                               usedTo: usedTo,
                                               postPhotosURL: post.postField.imagesURL)
                                .modifier(TabBarHidden())
                            } label: {
                                PostCell(usedTo: usedTo, post: post)
                            }
                        }
                    }
                } else {
                    ForEach(0..<4) { _ in
                        ShimmerPostCell()
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

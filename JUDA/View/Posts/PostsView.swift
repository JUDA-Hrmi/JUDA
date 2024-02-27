//
//  PostsView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// MARK: - 술상 탭
struct PostsView: View {
    @StateObject private var navigationRouter = NavigationRouter()
	@EnvironmentObject private var appViewModel: AppViewModel
	@EnvironmentObject private var authService: AuthService
	@EnvironmentObject private var postsViewModel: PostsViewModel
	@EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
	
	@FocusState private var isFocused: Bool
	
	var body: some View {
        NavigationStack(path: $navigationRouter.path) {
			VStack(spacing: 0) {
				// 상단 서치바
				SearchBar(inputText: $searchPostsViewModel.postSearchText, isFocused: $isFocused) {
					Task(priority: .high) {
						await searchPostsViewModel.postSearch(searchPostsViewModel.postSearchText)
					}
				}
				// 서치바 Text가 없을 때, 게시글 검색 결과 비워주기
				.onChange(of: searchPostsViewModel.postSearchText) { _ in
					if searchPostsViewModel.postSearchText == "" {
							searchPostsViewModel.searchPostsByUserName = []
							searchPostsViewModel.searchPostsByDrinkTag = []
							searchPostsViewModel.searchPostsByFoodTag = []
						}
					}
				// MARK: 검색어 입력 중
				if isFocused == true {
					VStack {
						Rectangle()
							.fill(.background)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
						Text("술상을 검색해보세요.")
							.font(.regular16)
							.foregroundStyle(.gray01)
						Rectangle()
							.fill(.background)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
					}
				// MARK: 검색 중
				} else if searchPostsViewModel.isLoading {
					
				// MARK: 검색 완료 / 결과 X
				} else if !searchPostsViewModel.postSearchText.isEmpty,
							searchPostsViewModel.searchPostsByUserName.isEmpty,
						  searchPostsViewModel.searchPostsByDrinkTag.isEmpty,
							searchPostsViewModel.searchPostsByFoodTag.isEmpty,
							isFocused == false {
					VStack {
						Rectangle()
							.fill(.background)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
						Text("검색된 술상이 없어요.")
							.font(.regular16)
							.foregroundStyle(.gray01)
						Rectangle()
							.fill(.background)
							.frame(maxWidth: .infinity, maxHeight: .infinity)
					}
				// MARK: 검색 완료 / 결과 O
				} else if !searchPostsViewModel.postSearchText.isEmpty,
							isFocused == false {
					PostSearchList(searchText: searchPostsViewModel.postSearchText)
				// MARK: 검색 X
				} else {
					HStack(alignment: .center) {
						// 인기, 최신 순으로 선택하여 정렬하기 위한 CustomSegment
						CustomTextSegment(segments: postsViewModel.postSortType.map { $0.rawValue },
										  selectedSegmentIndex: $postsViewModel.selectedSegmentIndex)
						.padding(.bottom, 14)
						.padding(.top, 20)
						//
						Spacer()
                        NavigationLink(value: Route.AddTag) {
                            Text("술상 올리기")
                                .font(.medium16)
                                .foregroundStyle(.mainBlack)
                        }
						// 비로그인 상태일 때 네비게이션링크 비활성화
						.opacity(authService.signInStatus ? 1.0 : 0.3)
						.disabled(!authService.signInStatus)
					}
					.padding(.horizontal, 20)
					// 인기 or 최신 탭뷰
					TabView(selection: $postsViewModel.selectedSegmentIndex) {
						ForEach(0..<PostSortType.allCases.count, id: \.self) { index in
							ScrollViewReader { value in
								Group {
									if postsViewModel.postSortType[index] == .popularity {
										// 인기순
										PostGrid(usedTo: .post, searchTagType: nil)
									} else {
										// 최신순
										PostGrid(usedTo: .post, searchTagType: nil)
									}
								}
								.onChange(of: postsViewModel.selectedSegmentIndex) { newValue in
									value.scrollTo(newValue, anchor: .center)
								}
							}
						}
					}
					.tabViewStyle(.page(indexDisplayMode: .never))
				}
			}
            .navigationDestination(for: Route.self) { value in
                switch value {
                case .ChangeUserName:
                    ChangeUserNameView()
                case .AddTag:
                    AddTagView()
                        .modifier(TabBarHidden())
                case .Login:
                    LogInView()
                        .modifier(TabBarHidden())
                case .NavigationPosts(let usedTo,
                                      let searchTagType,
                                      let taggedPostID,
                                      let selectedDrinkName,
                                      let selectedFoodTag):
                    NavigationPostsView(usedTo: usedTo,
                                        searchTagType: searchTagType,
                                        taggedPostID: taggedPostID,
                                        selectedDrinkName: selectedDrinkName,
                                        selectedFoodTag: selectedFoodTag)
                case .NavigationPostsTo(let usedTo,
                                        let searchTagType):
                    NavigationPostsView(usedTo: usedTo,
                                        searchTagType: searchTagType)
                    .modifier(TabBarHidden())
                case .NavigationProfile(let postUserName,
                                        let postUserID,
                                        let usedTo):
                    NavigationProfileView(postUserName: postUserName,
                                          postUserID: postUserID,
                                          usedTo: usedTo)
                case .Record(let recordType):
                    RecordView(recordType: recordType)
                //
                case .DrinkDetail(let drink):
                    DrinkDetailView(drink: drink)
                        .modifier(TabBarHidden())
                case .DrinkDetailWithUsedTo(let drink, let usedTo):
                    DrinkDetailView(drink: drink, usedTo: usedTo)
                        .modifier(TabBarHidden())
                //
                case .PostDetail(let postUserType,
                                 let post,
                                 let usedTo,
                                 let postPhotosURL):
                    PostDetailView(postUserType: postUserType,
                                   post: post,
                                   usedTo: usedTo,
                                   postPhotosURL: postPhotosURL)
                    .modifier(TabBarHidden())
                default:
                    ErrorPageView()
                        .modifier(TabBarHidden())

                }
            }
			// 키보드 내리기
			.onTapGesture {
				isFocused = false
			}
			.task {
				if postsViewModel.posts.isEmpty {
					await postFirstFetch()
				}
				// TODO: search용도 posts 배열에 게시글 패치
				if searchPostsViewModel.posts.isEmpty {
					await searchPostsViewModel.fetchPosts()
				}
			}
			.onChange(of: postsViewModel.selectedSegmentIndex) { _ in
				Task {
					await postReFetch()
				}
			}
			.onAppear {
				appViewModel.tabBarState = .visible
			}
		}
        .environmentObject(navigationRouter)
        .toolbar(appViewModel.tabBarState, for: .tabBar)
	}
	private func postFirstFetch() async {
		let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
		let query = postsViewModel.getPostSortType(postSortType: postSortType)
		await postsViewModel.firstFetchPost(query: query)
	}
	
	private func postReFetch() async {
		postsViewModel.isLoading = true
		postsViewModel.posts = []
		postsViewModel.postImagesURL = [:]
		postsViewModel.postThumbnailImagesURL = [:]
		let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
		let query = postsViewModel.getPostSortType(postSortType: postSortType)
		await postsViewModel.firstFetchPost(query: query)
	}
}

#Preview {
	PostsView()
}

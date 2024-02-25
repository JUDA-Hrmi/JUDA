//
//  PostsView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// MARK: - 술상 탭
struct PostsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
	@EnvironmentObject private var authService: AuthService
	@EnvironmentObject private var postsViewModel: PostsViewModel

    @FocusState private var isFocused: Bool
	
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 서치바
                SearchBar(inputText: $postsViewModel.postSearchText, isFocused: $isFocused) {  }
                HStack(alignment: .center) {
                    // 인기, 최신 순으로 선택하여 정렬하기 위한 CustomSegment
					CustomTextSegment(segments: postsViewModel.postSortType.map { $0.rawValue },
									  selectedSegmentIndex: $postsViewModel.selectedSegmentIndex)
                    .padding(.bottom, 14)
                    .padding(.top, 20)
                    //
                    Spacer()
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        AddTagView()
                            .modifier(TabBarHidden())
                    } label: {
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
									PostGrid()
                                } else {
                                    // 최신순
									PostGrid()
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
			.task {
				if postsViewModel.posts.isEmpty {
					let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
					let query = postsViewModel.getPostSortType(postSortType: postSortType)
					await postsViewModel.firstFetchPost(query: query)
				}
			}
			.onChange(of: postsViewModel.selectedSegmentIndex) { _ in
				Task {
					postsViewModel.isLoading = true
					postsViewModel.posts = []
					postsViewModel.postImages = [:]
					postsViewModel.postThumbnailImages = [:]
					let postSortType = postsViewModel.postSortType[postsViewModel.selectedSegmentIndex]
					let query = postsViewModel.getPostSortType(postSortType: postSortType)
					await postsViewModel.firstFetchPost(query: query)
				}
			}
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

#Preview {
	PostsView()
}

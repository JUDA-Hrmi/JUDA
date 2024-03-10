//
//  NavigationPostView.swift
//  JUDA
//
//  Created by Minjae Kim on 1/31/24.
//

import SwiftUI

// MARK: - 네비게이션 이동 시, 술상 화면
struct NavigationPostsView: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var postsViewModel: PostsViewModel
	@EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
	@State private var selectedSegmentIndex = 0
	let usedTo: WhereUsedPostGridContent
	let searchTagType: SearchTagType?

    // drink detail 에서 올때 받아야 할 정보
    var taggedPostID: [String]?
    var selectedDrinkName: String?
    // post detail 에서 올때 받아야 할 정보
	var selectedFoodTag: String?
    
    var titleText: String {
        switch usedTo {
        case .postSearch:
            return searchPostsViewModel.postSearchText
        case .postFoodTag:
            return selectedFoodTag ?? ""
        case .drinkDetail:
            return selectedDrinkName ?? ""
        default:
            return ""
        }
    }
    
    var body: some View {
        VStack {
            // 세그먼트 (인기 / 최신)
			CustomTextSegment(segments: searchPostsViewModel.postSortType.map { $0.rawValue },
                              selectedSegmentIndex: $selectedSegmentIndex)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            // 인기 or 최신 탭뷰
            TabView(selection: $selectedSegmentIndex) {
                ForEach(0..<PostSortType.list.count, id: \.self) { index in
                    ScrollViewReader { value in
                        Group {
                            if searchPostsViewModel.postSortType[index] == .popularity {
                                // 인기순
								PostGrid(usedTo: usedTo, searchTagType: searchTagType)
                            } else {
                                // 최신순
								PostGrid(usedTo: usedTo, searchTagType: searchTagType)
                            }
                        }
                        .onChange(of: selectedSegmentIndex) { newValue in
                            value.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
        }
        // 데이터 불러오기
        .task {
            if usedTo == .drinkDetail,
               let taggedPostID = taggedPostID,
               postsViewModel.drinkTaggedPosts.isEmpty {
                await postsViewModel.getTaggedPosts(taggedPostID: taggedPostID, sortType: .popularity)
                postsViewModel.isLoading = false
            }
			if usedTo == .postFoodTag, let selectedFoodTag = selectedFoodTag, let searchTagType = searchTagType {
				await searchPostsViewModel.postSearch(selectedFoodTag)
				await searchPostsViewModel.postSortBySearchTagType(searchTagType: searchTagType, postSortType: .popularity)
			}
        }
        // 데이터 변경
        .onChange(of: selectedSegmentIndex) { newValue in
            Task {
                // 최신 -> 인기
                if newValue == 0 {
                    if usedTo == .drinkDetail, let taggedPostID = taggedPostID {
                        await postsViewModel.getTaggedPosts(taggedPostID: taggedPostID, sortType: .popularity)
                        postsViewModel.isLoading = false
                    }
                // 인기 -> 최신
                } else {
                    if usedTo == .drinkDetail, let taggedPostID = taggedPostID {
                        await postsViewModel.getTaggedPosts(taggedPostID: taggedPostID, sortType: .mostRecent)
                        postsViewModel.isLoading = false
                    }
                }
            }
        }
		.onChange(of: selectedSegmentIndex) { _ in
			if let searchTagType = searchTagType {
				Task {
					await searchPostsViewModel
						.postSortBySearchTagType(searchTagType: searchTagType,
												 postSortType: searchPostsViewModel.postSortType[selectedSegmentIndex])
				}
			}
		}
		.task {
			if let searchTagType = searchTagType {
				await searchPostsViewModel
					.postSortBySearchTagType(searchTagType: searchTagType,
											 postSortType: searchPostsViewModel.postSortType[selectedSegmentIndex])
			}
		}
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    navigationRouter.back()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .principal) {
                Text(titleText)
                    .font(.medium16)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.mainBlack)
    }
}

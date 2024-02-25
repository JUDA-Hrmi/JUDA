//
//  NavigationPostView.swift
//  JUDA
//
//  Created by Minjae Kim on 1/31/24.
//

import SwiftUI

// MARK: - 네비게이션 이동 시, 술상 화면
struct NavigationPostsView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var postsViewModel: PostsViewModel

    var body: some View {
        VStack {
            // 세그먼트 (인기 / 최신)
            CustomTextSegment(segments: postsViewModel.postSortType.map { $0.rawValue },
                              selectedSegmentIndex: $postsViewModel.selectedSegmentIndex)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
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
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .principal) {
                Text(postsViewModel.postSearchText)
                    .font(.medium16)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.mainBlack)
    }
}

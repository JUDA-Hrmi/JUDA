//
//  NavigationPostView.swift
//  JUDA
//
//  Created by Minjae Kim on 1/31/24.
//

import SwiftUI

struct NavigationPostsView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var isLike = false
    @State private var likeCount = 45
    @State private var selectedSegmentIndex = 0

    let postSearchText: String
    
    var body: some View {
        VStack(spacing: 0) {
            // 세그먼트 (인기 / 최신)
            CustomTextSegment(segments: PostOrLiked.post, selectedSegmentIndex: $selectedSegmentIndex)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
                
            TabView(selection: $selectedSegmentIndex) {
                ForEach(0..<PostOrLiked.post.count, id: \.self) { index in
                    ScrollViewReader { value in
                        Group {
                            if index == 0 {
                                // 인기순
                                PostGrid(isLike: $isLike, likeCount: $likeCount, postUserType: .reader)
                            } else {
                                // 최신순
                                PostGrid(isLike: $isLike, likeCount: $likeCount, postUserType: .writter)
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
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    // TODO: NavigationStack path remove
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                }
            }
            ToolbarItem(placement: .principal) {
                Text(postSearchText)
                    .font(.semibold16)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.mainBlack)
    }
}

#Preview {
	NavigationPostsView(postSearchText: "대방어")
}

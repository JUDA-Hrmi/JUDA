//
//  LikedPostGrid.swift
//  JUDA
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// MARK: - 술상 리스트 탭 화면
struct LikedPostGrid: View {
    // 현재 유저가 해당 술 상을 좋아요 눌렀는지 bool
    @State private var isLikePost = true
    // 게시물
    @State private var postLikeCount = 45

    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                LikedDrinkGridContent(isLikePost: $isLikePost, postLikeCount: $postLikeCount)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                LikedDrinkGridContent(isLikePost: $isLikePost, postLikeCount: $postLikeCount)
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    LikedDrinkGridContent(isLikePost: $isLikePost, postLikeCount: $postLikeCount)
                }
            }
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 술상 그리드
struct LikedDrinkGridContent: View {
    // 현재 유저가 해당 술 상을 좋아요 눌렀는지 bool
    @Binding var isLikePost: Bool
    // 게시물
    @Binding var postLikeCount: Int
    // UITest - 술상 그리드 셀 2개 column
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(0..<8, id: \.self) { _ in
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
                    PostDetailView(postUserType: .reader, nickName: "Hrmi", isLike: $isLikePost, likeCount: $postLikeCount)
                        .modifier(TabBarHidden())
                } label: {
                    PostCell(isLike: $isLikePost, likeCount: $postLikeCount)
                }
                .buttonStyle(EmptyActionStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    LikedPostGrid()
}

//
//  LikedPostGrid.swift
//  JUDA
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// MARK: - 술상 리스트 탭 화면
struct LikedPostGrid: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        if let user = authService.currentUser,
           !user.likedPosts.isEmpty {
            // MARK: iOS 16.4 이상
            if #available(iOS 16.4, *) {
                ScrollView() {
                    LikedPostGridContent()
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                // MARK: iOS 16.4 미만
            } else {
                ViewThatFits(in: .vertical) {
					LikedPostGridContent()
                        .frame(maxHeight: .infinity, alignment: .top)
                    ScrollView {
						LikedPostGridContent()
                    }
                }
            }
        } else {
            Text("좋아하는 술상이 없어요!")
                .font(.medium16)
                .foregroundStyle(.mainBlack)
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 술상 그리드
struct LikedPostGridContent: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var likedViewModel: LikedViewModel

    // 술상 그리드 셀 2개 column
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            if !likedViewModel.isLoading {
                ForEach(likedViewModel.likedPosts, id: \.postField.postID) { post in
                    NavigationLink(value: Route
                        .PostDetail(postUserType: authService.currentUser?.userID == post.userField.userID ? .writter : .reader,
                                    post: post,
                                    usedTo: .liked,
                                    postPhotosURL: post.postField.imagesURL)) {
                        PostCell(usedTo: .liked, post: post)
                    }
                    .buttonStyle(EmptyActionStyle())
                }
            } else {
                ForEach(0..<6) { _ in
                    ShimmerPostCell()
                }
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    LikedPostGrid()
}

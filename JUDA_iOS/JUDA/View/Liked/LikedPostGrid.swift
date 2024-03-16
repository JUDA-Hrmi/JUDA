//
//  LikedPostGrid.swift
//  JUDA
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// MARK: - 술상 리스트 탭 화면
struct LikedPostGrid: View {
    @EnvironmentObject private var authViewModel: AuthViewModel

    var body: some View {
        if let user = authViewModel.currentUser,
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
    @EnvironmentObject private var authViewModel: AuthViewModel

    // 술상 그리드 셀 2개 column
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        if let user = authViewModel.currentUser, 
            !user.likedPosts.isEmpty {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(user.likedPosts, id: \.postField.postID) { post in
                    NavigationLink(value: Route
                        .PostDetail(postUserType: user.userField.userID == post.postField.user.userID ? .writter : .reader,
                                    post: post,
                                    usedTo: .liked)) {
                        PostCell(usedTo: .liked, post: post)
                    }
                                    .buttonStyle(EmptyActionStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    LikedPostGrid()
}

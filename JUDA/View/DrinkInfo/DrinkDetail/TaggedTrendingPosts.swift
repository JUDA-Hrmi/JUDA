//
//  TaggedTrendingPosts.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 태그된 인기 술상
struct TaggedTrendingPosts: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var postsViewModel: PostsViewModel

    @State private var posts: [Post] = []
    @State private var isLoading: Bool = true
    let drink: FBDrink

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("태그된 인기 술상")
                .font(.semibold18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            VStack(spacing: 0) {
                ForEach(posts, id: \.postField.postID) { post in
                    NavigationLink(value: Route
                        .PostDetail(postUserType: post.userField.userID == authService.currentUser?.userID ? .writter : .reader,
                                    post: post,
                                    usedTo: .drinkDetail,
                                    postPhotosURL: post.postField.imagesURL)) {
                        if !isLoading {
                            if let user = authService.currentUser {
                                PostListCell(post: post,
                                             isLiked: user.likedPosts.contains(post.postField.postID ?? ""))
                            } else {
                                PostListCell(post: post,
                                             isLiked: false)
                            }
                        } else {
                            ShimmerPostListCell()
                        }
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .task {
            // 태그된 인기 게시물 가져오기
            self.isLoading = true
            if posts.isEmpty {
                self.posts = await postsViewModel.getTopTrendingPosts(taggedPostID: drink.taggedPostID)
            }
            self.isLoading = false
        }
    }
}

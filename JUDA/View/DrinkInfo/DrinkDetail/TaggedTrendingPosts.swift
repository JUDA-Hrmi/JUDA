//
//  TaggedTrendingPosts.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 태그된 인기 술상
struct TaggedTrendingPosts: View {
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
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        PostDetailView(postUserType: post.userField.userID == authService.uid ? .writter : .reader,
                                       post: post,
                                       postPhotos: post.postField.imagesURL)
                    } label: {
                        if !isLoading {
                            PostListCell(post: post)
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
            self.posts = await postsViewModel.fetchTaggedTrendingPosts(taggedPostID: drink.taggedPostID)
            self.isLoading = false
        }
    }
}

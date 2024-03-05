//
//  PostTopView.swift
//  JUDA
//
//  Created by 백대홍 on 2/26/24.
//

import SwiftUI

struct PostTopView: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var mainViewModel: MainViewModel
	@EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text("인기 술상")
                    .font(.semibold20)
                
                Spacer()
                
                Button {
					appViewModel.selectedTabIndex = 2
                } label: {
                    Text("더보기")
                        .foregroundStyle(.gray01)
                        .font(.semibold16)
                }
            }
            .padding(20)

            ForEach(mainViewModel.posts, id: \.postField.postID) { post in
                NavigationLink(value: Route
                    .PostDetail(postUserType: authService.currentUser?.userID == post.userField.userID ? .writter : .reader,
                                post: post,
                                usedTo: .main,
                                postPhotosURL: post.postField.imagesURL)) {
                    if let user = authService.currentUser {
                        PostListCell(post: post,
                                     isLiked: user.likedPosts.contains(post.postField.postID ?? ""))
                    } else {
                        PostListCell(post: post,
                                     isLiked: false)
                    }
                }
            }
        }
    }
}

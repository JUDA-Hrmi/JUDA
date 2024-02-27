//
//  PostTopView.swift
//  JUDA
//
//  Created by 백대홍 on 2/26/24.
//

import SwiftUI

struct PostTopView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    @Binding var selectedTabIndex: Int
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text("인기 술상")
                    .font(.semibold20)
                
                Spacer()
                
                Button {
                    selectedTabIndex = 2
                } label: {
                    Text("더보기")
                        .foregroundStyle(.gray01)
                        .font(.semibold16)
                }
            }
            .padding(20)

            ForEach(mainViewModel.posts, id: \.postField.postID) { post in
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
                    PostDetailView(postUserType: authService.uid == post.userField.userID ? .writter : .reader,
                                   post: post,
								   usedTo: .drinkDetail,
								   postPhotosURL: post.postField.imagesURL)
                    .modifier(TabBarHidden())
                } label: {
                    PostListCell(post: post,
                                 isLiked: authService.likedPosts.contains(post.postField.postID ?? ""))
                }
            }
        }
    }
}

//
//  PostGrid.swift
//  JUDA
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

// MARK: - 스크롤 뷰 or 뷰 로 보여질 post grid
struct PostGrid: View {
    @State private var scrollAxis: Axis.Set = .vertical
    @State private var vHeight = 0.0
    
	@Binding var isLike: Bool
	@Binding var likeCount: Int
	
	let postUserType: PostUserType
	
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                PostGridContent(isLike: $isLike,
                                      likeCount: $likeCount,
                                      postUserType: postUserType)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollDismissesKeyboard(.immediately)
            .refreshable {
                // TODO: write post data refresh code
            }
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                PostGridContent(isLike: $isLike,
                                      likeCount: $likeCount,
                                      postUserType: postUserType)
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    PostGridContent(isLike: $isLike,
                                          likeCount: $likeCount,
                                          postUserType: postUserType)
                }
                .scrollDismissesKeyboard(.immediately)
                .refreshable {
                    // TODO: write post data refresh code
                }
            }
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 post grid 내용 부분
struct PostGridContent: View {
    @Binding var isLike: Bool
    @Binding var likeCount: Int
    
    let postUserType: PostUserType

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(0..<12, id: \.self) { _ in
                NavigationLink {
                    PostDetailView(postUserType: postUserType,
                                   nickName: "hrmi",
                                   isLike: $isLike,
                                   likeCount: $likeCount)
                        .modifier(TabBarHidden())
                } label: {
                    PostCell(isLike: $isLike, likeCount: $likeCount)
                }
                .buttonStyle(EmptyActionStyle())
            }
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
	PostGrid(isLike: .constant(false), likeCount: .constant(45), postUserType: PostUserType.reader)
}

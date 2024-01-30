//
//  LikedPostGrid.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

struct LikedPostGrid: View {
    @State private var scrollAxis: Axis.Set = .vertical
    @State private var vHeight = 0.0
    // 현재 유저가 해당 술 상을 좋아요 눌렀는지 bool
    @State private var isLikePost = true
    // 게시물
    @State private var postLikeCount = 45
    // UITest - 술상 그리드 셀 2개 column
    private let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        CustomScrollView(scrollAxis: $scrollAxis,
                         vHeight: $vHeight) {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(0..<8, id: \.self) { _ in
                    // TODO: 추후에 네비게이션으로 해당 술상의 Detail 로 이동 연결
                    PostCell(isLike: $isLikePost, likeCount: $postLikeCount)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    LikedPostGrid()
}

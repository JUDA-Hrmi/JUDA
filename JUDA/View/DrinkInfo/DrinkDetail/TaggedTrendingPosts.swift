//
//  TaggedTrendingPosts.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// UITest Data - 해당 술이 태그된 인기 게시물 3개를 담은 리스트
struct TaggedTrendingPostsDummyData: Identifiable {
    let id = UUID()
    var image: String
    let author: String
    var tags: [String]
    var postLikesCount: Int
    
    static let sampleDataList: [TaggedTrendingPostsDummyData] = [
        .init(image: "foodEx1", author: "nelchupapa", tags: ["대방어", "새우튀김", "뭐먹었지"], postLikesCount: 45),
        .init(image: "foodEx3", author: "mangJae", tags: ["초밥", "스시", "와인"], postLikesCount: 1_235),
        .init(image: "foodEx5", author: "phang", tags: ["닭구이", "소맥", "꽈리고추", "하이볼", "????"], postLikesCount: 2_423_481)
    ]
}

// MARK: - 태그된 인기 술상
struct TaggedTrendingPosts: View {
    // UITest - Post Dummy Data List
    private let sampleDataList = TaggedTrendingPostsDummyData.sampleDataList
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("태그된 인기 술상")
                .font(.semibold18)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
            VStack(spacing: 0) {
                ForEach(sampleDataList) { data in
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
//                        PostDetailView(postUserType: .reader, nickName: data.author, isLike: .constant(false), likeCount: .constant(data.postLikesCount))
                    } label: {
                        PostListCell(postDummyData: data)
                    }
                }
            }
        }
        .padding(.vertical, 10)
    }
}

#Preview {
    TaggedTrendingPosts()
}

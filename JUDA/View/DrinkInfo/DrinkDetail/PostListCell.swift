//
//  PostListCell.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 태그된 인기 술상에 보여줄 술상 셀
struct PostListCell: View {
    // UITest - Post DummyData
    let postDummyData: TaggedTrendingPostsDummyData
    // 제안 - 여기서는 하트를 눌러서 on off 하지 않고, 현재 유저가 좋아요 눌렀는지만 체크하는 것?
    private let isLiked = false
    @State private var windowWidth: CGFloat = 0

    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Post 이미지
            Image(postDummyData.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipped()
                .clipShape(.rect(cornerRadius: 5))
            // 유저, 태그, 좋아요
            VStack(alignment: .leading, spacing: 6) {
                // 유저
                Text(postDummyData.author)
                    .font(.regular16)
                // 태그
                Text(getTagListToString(list: postDummyData.tags))
                    .font(.light14)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 좋아요
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.regular14)
                        .foregroundStyle(isLiked ? Color.red : Color.gray)
                    // 좋아요 숫자 1000 넘으면 k, 1000000 넘으면 m 으로 변경
                    Text(Formatter.formattedPostLikesCount(postDummyData.postLikesCount))
                        .font(.regular14)
                        .foregroundStyle(.gray01)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // DrinkDetailView - TaggedTrendingPosts 에서 태그 한줄로 보여주기 위한 리스트 map + join 함수
    private func getTagListToString(list: [String]) -> String {
        let tagString = "# "
        let spacing = "    "
        return list.map { tagString + $0 }.joined(separator: spacing)
    }
}

#Preview {
    PostListCell(postDummyData: TaggedTrendingPostsDummyData.sampleDataList.last!)
}

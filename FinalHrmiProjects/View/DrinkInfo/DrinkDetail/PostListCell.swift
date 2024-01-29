//
//  PostListCell.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

struct PostListCell: View {
    // UITest - Post DummyData
    let postDummyData: TaggedTrendingPostsDummyData
    // 제안 - 여기서는 하트를 눌러서 on off 하지 않고, 현재 유저가 좋아요 눌렀는지만 체크하는 것?
    private let isLiked = false
    
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
                // TODO: 태그가 여러줄이 되면.. 어떻게 보여줄지, 코드 구성 다시하기
                HStack(alignment: .center, spacing: 16) {
                    ForEach(postDummyData.tags, id: \.self) { tag in
                        Text("# \(tag)")
                            .font(.light14)
                    }
                }
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
}

#Preview {
    PostListCell(postDummyData: TaggedTrendingPostsDummyData.sampleDataList.first!)
}

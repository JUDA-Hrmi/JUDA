//
//  PostListCell.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI
import Kingfisher

// MARK: - 태그된 인기 술상에 보여줄 술상 셀
struct PostListCell: View {
    let post: Post
    
    // 여기서는 하트를 눌러서 on off 하지 않고, 현재 유저가 좋아요 눌렀는지만 체크하는 것
    @State private var isLiked: Bool
    @State private var windowWidth: CGFloat = 0

    init(post: Post, isLiked: Bool) {
        self.post = post
        _isLiked = State(initialValue: isLiked)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            // Post 이미지
            KFImage.url(post.postField.imagesURL.first)
                .placeholder {
                    CircularLoaderView(size: 20)
                        .frame(width: 70, height: 70)
                }
                .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
                .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
                .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
                .fade(duration: 0.2) // 이미지 부드럽게 띄우기
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .clipped()
                .clipShape(.rect(cornerRadius: 5))
            // 유저, 태그, 좋아요
            VStack(alignment: .leading, spacing: 6) {
                // 유저
                Text(post.postField.user.userName)
                    .font(.regular16)
                    .foregroundStyle(.mainBlack)
                // 태그
                Text(Formatter.getTagListToString(list: Array(post.postField.foodTags.prefix(2))))
                    .font(.light14)
                    .foregroundStyle(.mainBlack)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 좋아요
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .font(.regular14)
                        .foregroundStyle(isLiked ? .mainAccent01 : .gray01)
                    // 좋아요 숫자 1000 넘으면 k, 1000000 넘으면 m 으로 변경
                    Text(Formatter.formattedPostLikesCount(post.likedUsersID.count))
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

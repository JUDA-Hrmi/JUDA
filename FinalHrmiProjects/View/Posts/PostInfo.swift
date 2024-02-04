//
//  PostInfo.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

struct PostInfo: View {
    
    let userName: String
    let profileImageName: String
    let postUploadDate: String
    @Binding var isLike: Bool
    @Binding var likeCount: Int
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        HStack {
            // 사용자의 프로필 사진
            NavigationLink(destination: {
                NavigationProfileView(userType: UserType.otheruser)
            }, label: {
                Image(profileImageName)
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(.circle)
                
                VStack(alignment: .leading) {
                    // 사용자의 닉네임
                    Text(userName)
                        .lineLimit(1)
                        .font(.regular18)
                        .foregroundStyle(.mainBlack)
                    // 게시글 올린 날짜
                    Text(postUploadDate)
                        .font(.regular14)
                        .foregroundStyle(.gray01)
                }
            })
            
            Spacer()
            
            // 좋아요 버튼
            HStack(spacing: 3) {
                // 좋아요를 등록 -> 빨간색이 채워진 하트
                // 좋아요를 해제 -> 테두리가 회색인 하트
                Image(systemName: isLike ? "heart.fill" : "heart")
                    .foregroundStyle(isLike ? .mainAccent01 : .gray01)
                // TODO: fomat 변경
                Text(Formatter.formattedPostLikesCount(likeCount))
                    .foregroundStyle(.gray01)
            }
            .font(.regular16)
            .onTapGesture {
                likeButtonAction()
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
    }
    
    // 좋아요 버튼 액션 메서드
    private func likeButtonAction() {
        // 좋아요 등록 -> 좋아요 수에 + 1
        // 좋아요 해제 -> 좋아요 수에 - 1
        if isLike {
            likeCount -= 1
        } else {
            likeCount += 1
        }
        isLike.toggle()
    }
}

#Preview {
    PostInfo(userName: "hrmi", profileImageName: "appIcon", postUploadDate: "2023.12.08", isLike: .constant(false), likeCount: .constant(45))
}

//
//  NavigationProfileView.swift
//  JUDA
//
//  Created by 백대홍 on 2/4/24.
//

import SwiftUI

// MARK: - 네비게이션 이동 시, 유저 프로필 화면
struct NavigationProfileView: View {
    @Environment(\.dismiss) private var dismiss

    @State var isLike: Bool = true
    @State var likeCount: Int = 303
    
    let userType: UserType
    let userName: String
    
    var body: some View {
        VStack {
            // 프로필 사진 -- 닉네임 -- 수정
            UserProfileView(userType: .otheruser)
            // 내가 작성한 게시물 -- 술상 올리기
            HStack {
                userType == .user ? Text("내가 작성한 술상") : Text("\(userName) 님이 작성한 술상")
                    .font(.semibold18)
                Spacer()
                
                if userType == .user {
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        AddTagView()
                            .modifier(TabBarHidden())
                    } label: {
                        Text("술상 올리기")
                            .font(.light14)
                            .foregroundStyle(.mainBlack)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            // 사용자가 작성한 글
            // MARK: iOS 16.4 이상
            if #available(iOS 16.4, *) {
                ScrollView() {
                    PostGridContent(isLike: $isLike, likeCount: $likeCount, postUserType: .writter)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                // MARK: iOS 16.4 미만
            } else {
                ViewThatFits(in: .vertical) {
                    PostGridContent(isLike: $isLike, likeCount: $likeCount, postUserType: .writter)
                        .frame(maxHeight: .infinity, alignment: .top)
                    ScrollView {
                        PostGridContent(isLike: $isLike, likeCount: $likeCount, postUserType: .writter)
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.mainBlack)
                }
            }
            ToolbarItem(placement: .principal) {
                userType == .user ? Text("마이페이지") : Text("\(userName) 님의 페이지")
                    .font(.medium16)
            }
        }
        .navigationBarBackButtonHidden()
    }
}


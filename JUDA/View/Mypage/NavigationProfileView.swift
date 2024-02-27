//
//  NavigationProfileView.swift
//  JUDA
//
//  Created by 백대홍 on 2/4/24.
//

import SwiftUI

// MARK: - 네비게이션 이동 시, 유저 프로필 화면
struct NavigationProfileView: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    let postUserName: String
    let postUserID: String
    let usedTo: WhereUsedPostGridContent
    var userType: UserType {
        postUserID == authService.uid ? .user : .otheruser
    }
    
    var body: some View {
        VStack {
            // 프로필 사진 -- 닉네임 -- 수정
            UserProfileView(userType: userType,
                            userName: postUserName,
                            userID: postUserID,
                            usedTo: usedTo)
            // 내가 작성한 게시물 -- 술상 올리기
            HStack {
                userType == .user ? Text("내가 작성한 술상") : Text("\(postUserName) 님이 작성한 술상")
                    .font(.semibold18)
                Spacer()
                
                if userType == .user {
                    NavigationLink(value: Route.AddTag) {
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
                    PostGridContent(usedTo: .myPage,
                                    searchTagType: nil,
                                    userType: userType)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                // MARK: iOS 16.4 미만
            } else {
                ViewThatFits(in: .vertical) {
                    PostGridContent(usedTo: .myPage,
                                    searchTagType: nil,
                                    userType: userType)                 
                    .frame(maxHeight: .infinity, alignment: .top)
                    ScrollView {
                        PostGridContent(usedTo: .myPage,
                                        searchTagType: nil,
                                        userType: userType)
                    }
                }
            }
        }
        // 작성한 술상 데이터 가져오기
        .task {
            await myPageViewModel.getUsersPosts(userID: userType == .user ? authService.uid : postUserID,
                                                userType: userType)
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    navigationRouter.back()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.mainBlack)
                }
            }
            ToolbarItem(placement: .principal) {
                userType == .user ? Text("마이페이지") : Text("\(postUserName) 님의 페이지")
                    .font(.medium16)
            }
        }
        .navigationBarBackButtonHidden()
    }
}


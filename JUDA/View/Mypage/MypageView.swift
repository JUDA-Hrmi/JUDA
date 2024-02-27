//
//  MypageView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI
import FirebaseAuth

// MARK: - 마이페이지 탭
struct MypageView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    
    @Binding var selectedTabIndex: Int

    var body: some View {
        NavigationStack {
            VStack {
                // 프로필 사진 -- 닉네임 -- 수정
                UserProfileView(userType: UserType.user,
                                userName: authService.name,
                                userID: authService.uid,
                                usedTo: .myPage)
                // 내가 작성한 게시물 -- '새 글 작성하기'
                HStack {
                    Text("내가 작성한 술상")
                        .font(.semibold18)
                    Spacer()
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        // 글 작성 페이지로 이동
                        AddTagView()
                            .modifier(TabBarHidden())
                    } label: {
                        Text("술상 올리기")
                            .font(.medium16)
                            .foregroundStyle(.mainBlack)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                // 사용자가 작성한 글
                // MARK: iOS 16.4 이상
                if #available(iOS 16.4, *) {
                    ScrollView() {
						PostGridContent(usedTo: .myPage, searchTagType: nil)
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                    // MARK: iOS 16.4 미만
                } else {
                    ViewThatFits(in: .vertical) {
						PostGridContent(usedTo: .myPage, searchTagType: nil)
                            .frame(maxHeight: .infinity, alignment: .top)
                        ScrollView {
							PostGridContent(usedTo: .myPage, searchTagType: nil)
                        }
                    }
                }
            }
            // 작성한 술상 데이터 가져오기
            .task {
                if myPageViewModel.userPosts.isEmpty {
                    await myPageViewModel.getUsersPosts(userID: authService.uid, userType: .user)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("마이페이지")
                        .font(.semibold18)
                }
                // 알람 모아보는 뷰
                ToolbarItem(placement: .topBarTrailing) {
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        AlarmStoreView()
                            .modifier(TabBarHidden())
                    } label: {
                        Image(systemName: "bell")
                    }
                }
                // 환경설정 세팅 뷰
                ToolbarItem(placement: .topBarTrailing) {
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        SettingView(selectedTabIndex: $selectedTabIndex)
                            .modifier(TabBarHidden())
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .foregroundStyle(.mainBlack)
            .onAppear {
                appViewModel.tabBarState = .visible
                authService.startListeningForUser()
            }
        }
        .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

//
//  MypageView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct MypageView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    // MARK: 데이터 구조 정해지면 바꿔야되는 부분
    @State var isLike: Bool = true
    @State var likeCount: Int = 303
    
    var body: some View {
        NavigationStack {
            VStack {
                // MARK: - [프로필 사진 -- 닉네임 -- '수정']
                UserProfileView(userType: UserType.user)
                
                // MARK: - [내가 작성한 게시물 -- '새 글 작성하기']
                HStack {
                    Text("내가 작성한 술상")
                        .font(.semibold18)
                    Spacer()
                    NavigationLink {
                        // 글 작성하는 페이지로 이동하기
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
                        PostGridContent(isLike: $isLike, likeCount: $likeCount, postUserType: .writter)
                    }
                    .scrollBounceBehavior(.basedOnSize, axes: .vertical)
                    .scrollIndicators(.hidden)
                    .padding(.horizontal, 20)
                    // MARK: iOS 16.4 미만
                } else {
                    ViewThatFits(in: .vertical) {
                        PostGridContent(isLike: $isLike, likeCount: $likeCount, postUserType: .writter)
                            .frame(maxHeight: .infinity, alignment: .top)
                        ScrollView {
                            PostGridContent(isLike: $isLike, likeCount: $likeCount, postUserType: .writter)
                        }
                        .scrollIndicators(.hidden)
                    }
                    .padding(.horizontal, 20)
                }
            }
            // MARK: - [마이페이지 -- '알림' | '설정']
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Text("마이페이지")
                        .font(.semibold18)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    // MARK: - 알람 모아보는 뷰
                    NavigationLink {
                        // TODO: AlarmStoreView 파일 있을 때 주석 제거하기
                        AlarmStoreView()
                            .modifier(TabBarHidden())
                    } label: {
                        Image(systemName: "bell")
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    // MARK: - SettingView 이동을 위한 버튼
                    NavigationLink {
                        SettingView()
                            .modifier(TabBarHidden())
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .foregroundStyle(.mainBlack)
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

#Preview {
    MypageView()
}

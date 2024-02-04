//
//  MypageView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct MypageView: View {
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
                    Text("내가 작성한 게시글")
                        .font(.semibold18)
                    Spacer()
                    NavigationLink {
                        // 글 작성하는 페이지로 이동하기
                        AddTagView()
                    } label: {
                        Text("새 글 작성하기")
                            .font(.light14)
                            .foregroundStyle(.mainBlack)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                
                // MARK: - [LazyVGrid - 사용자가 작성한 글]
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(0..<4) { _ in
                            NavigationLink {
                                // TODO: PostCell에 해당하는 DetailView로 이동하기
                                PostDetailView(postUserType: .writter, nickName: "hrmi", isLike: .constant(false), likeCount: .constant(45))
                            } label: {
                                // TODO: 네비게이션 루트 설정
                                // 글 누르고 back눌렀을 때 마이페이지로 다시 돌아올지 PostsView에서 있을지 루트 잘 설정해야할 듯
                                PostCell(isLike: $isLike, likeCount: $likeCount)
                            }
                            // Blinking 애니메이션 삭제
                            .buttonStyle(EmptyActionStyle())
                        }
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
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        // MARK: - 알람 모아보는 뷰
                        NavigationLink {
                            // TODO: AlarmStoreView 파일 있을 때 주석 제거하기
                            AlarmStoreView()
                        } label: {
                            Image(systemName: "bell")
                        }
                        // MARK: - SettingView 이동을 위한 버튼
                        NavigationLink {
                            SettingView()
                        } label: {
                            Image(systemName: "gearshape")
                        }
                    }
                    .foregroundStyle(.mainBlack)
                }
            }
        }
    }
}

#Preview {
    MypageView()
}

//
//  NavigationProfileView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 2/4/24.
//

import SwiftUI

struct NavigationProfileView: View {
    @State var isLike: Bool = true
    @State var likeCount: Int = 303
    let userType: UserType
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        VStack {
            // MARK: - [마이페이지 -- '알림' | '설정']
            HStack {
                userType == .user ? Text("마이페이지") : Text("sayHong님의 페이지")
                    .font(.semibold18)
                
                Spacer()
                
                if userType == .user {
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
                } else {
                    
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            // MARK: - [프로필 사진 -- 닉네임 -- '수정']
            
            UserProfileView(userType: .otheruser)
            
            // MARK: - [내가 작성한 게시물 -- '새 글 작성하기']
            HStack {
                userType == .user ? Text("내가 작성한 게시물") : Text("sayHong님이 작성한 페이지")
                    .font(.semibold18)
                Spacer()
                
                if userType == .user {
                    NavigationLink {
                        // 글 작성하는 페이지로 이동하기
                        AddTagView()
                    } label: {
                        Text("새 글 작성하기")
                            .font(.light14)
                            .foregroundStyle(.mainBlack)
                    }
                } else {
                    
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.mainBlack)
                }
            }
        }
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    NavigationProfileView(userType: UserType.otheruser)
}

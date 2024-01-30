//
//  MypageView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct MypageView: View {
    @State var isLike: Bool = true
    @State var likeCount: Int = 303
    
    var body: some View {
        NavigationStack {
            // MARK: - Section 1
            HStack {
                Text("마이페이지")
                    .font(.semibold18)
                Spacer()
                HStack {
                    // MARK: - 알람 모아보는 뷰
                    NavigationLink {
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
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            // MARK: - Section 2
            HStack {
                UserProfileView()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            
            // MARK: - Section 3
            HStack {
                Text("내가 작성한 게시글")
                    .font(.semibold18)
                Spacer()
                NavigationLink {
                    RecordView()
                } label: {
                    Text("새 글 작성하기")
                        .font(.light14)
                        .foregroundStyle(.mainBlack)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            
            // MARK: - Section 4
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(0..<4) { _ in
                        NavigationLink {
                            // TODO: PostCell에 해당하는 DetailView로 이동하기
//                            PostsDetailView()
                        } label: {
                            // TODO: 네비게이션 루트 설정
                            // 글 누르고 back눌렀을 때 마이페이지로 다시 돌아올지 PostsView에서 있을지 루트 잘 설정하기
                            PostCell(isLike: $isLike, likeCount: $likeCount)
                        }
                        // Blinking 애니메이션 삭제
                        .buttonStyle(EmptyActionStyle())
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    MypageView()
}

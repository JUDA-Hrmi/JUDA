//
//  MypageView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct MypageView: View {
    @State var userName: String = "sayHong"
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
                HStack(spacing: 20) {
                    HStack(alignment: .bottom, spacing: -15) {
                        // 사용자 프로필 이미지
                        Image("appIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 70, height: 70)  // 원의 크기 조절
                            .overlay(Circle().stroke(Color.gray01, lineWidth: 2))  // 원 테두리 추가
                        
                        // TODO: 수정 버튼 클릭 -> 사진 선택하는 뷰로 갈 것.
                        // 커스텀 시트 쓸 지 액션시트 쓸지 정하기
                        // 밑에서 아래로 올라오는 뷰 이동 방식이 좋을 것 같기동
                        NavigationLink {
                            SelectedProfilePhotoView()
                        } label: {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.gray01)
                        }
                        
                    }
                    Text(userName)
                        .font(.medium18)
                }
                Spacer()
                
                // MARK: - 닉네임 수정 -> 네비뷰인가 텍필 수정인가?
                NavigationLink {
                    // TODO: [기능] 네비로 할 지 텍필 수정으로 할지 확인 후 수정하기
                } label: {
                    Text("닉네임 수정")
                        .font(.light14)
                        .foregroundStyle(.gray01)
                }
                
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

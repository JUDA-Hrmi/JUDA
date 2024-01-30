//
//  UserProfileView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI

struct UserProfileView: View {
    @State var userNickName: String = "sayHong" // 사용자 닉네임
    
    @State private var isLibraryPresented: Bool = false // PhotoPicker - 라이브러리에서 선택
    @State private var userProfilePhoto: UIImage? // 사용자 프로필 이미지
    var body: some View {
        HStack {
            HStack(spacing: 20) {
                HStack(alignment: .bottom, spacing: -15) {
                    // 사용자 프로필 이미지
                    if let image = userProfilePhoto { // 사용자 지정 이미지가 있을 때 (이미지 선택 완료했을 경우)
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 70, height: 70)  // 원의 크기 조절
                            .overlay(Circle().stroke(Color.gray01, lineWidth: 2))  // 원 테두리 추가
                    } else {
                        // 사용자 지정 이미지가 없을 때 기본 이미지로 설정
                        // TODO: 기본 이미지 파일 지정해서 넣기
                        Image("appIcon")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 70, height: 70)
                            .overlay(Circle().stroke(Color.gray01, lineWidth: 2))
                    }
                    // 프로필 사진 수정 버튼
                    Button(action: {
                        isLibraryPresented.toggle()
                    }, label: {
                        Image(systemName: "pencil.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.gray01)
                    })
                    .fullScreenCover(isPresented: $isLibraryPresented, content: {
                        ProfilePhotoPicker(selectedPhoto: $userProfilePhoto,
                                           isLibraryPresented: $isLibraryPresented)
                    })
                    
                }
                // MARK: 사용자 닉네임 표시
                Text(userNickName)
                    .font(.medium18)
                Spacer()
                
                NavigationLink {
                    ChangeUserNameView(userNickName: $userNickName)
                } label: {
                    Text("닉네임 수정")
                        .font(.light14)
                        .foregroundStyle(.gray01)
                }

            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    UserProfileView()
}

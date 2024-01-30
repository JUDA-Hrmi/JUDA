//
//  UserProfileView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/30.
//

import SwiftUI

struct UserProfileView: View {
    @State var userName: String = "sayHong"
    
    @State private var isLibraryPresented: Bool = false // PhotoPicker - 라이브러리에서 선택
    @State private var userProfilePhoto: UIImage?
    var body: some View {
        HStack(spacing: 20) {
            HStack(alignment: .bottom, spacing: -15) {
                // 사용자 프로필 이미지
                if let image = userProfilePhoto {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .frame(width: 70, height: 70)  // 원의 크기 조절
                        .overlay(Circle().stroke(Color.gray01, lineWidth: 2))  // 원 테두리 추가
                } else {
                    // 사용자 지정 이미지가 없을 때 기본 이미지로 설정
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
                .sheet(isPresented: $isLibraryPresented, content: {
                    ProfilePhotoPicker(selectedPhoto: $userProfilePhoto,
                                       isLibraryPresented: $isLibraryPresented)
                })
                
            }
            // MARK: 텍스트 필드 버전
            Text(userName)
                .font(.medium18)
            Spacer()
            
            NavigationLink {
                ChangeUserNameView(userNickName: $userName)
            } label: {
                Text("닉네임 수정")
                    .font(.light14)
                    .foregroundStyle(.gray01)
            }

        }
    }
}

#Preview {
    UserProfileView()
}

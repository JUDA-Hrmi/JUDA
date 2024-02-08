//
//  UserProfileView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/02/01.
//

import SwiftUI
import PhotosUI

enum UserType {
    case user, otheruser
}

struct UserProfileView: View {
    @State private var userNickName: String = "sayHong" // 사용자 닉네임
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var userProfileImage: UIImage? // 사용자 프로필 이미지
    
    let userType: UserType
    
    // 이미지 가져오다가 에러나면 띄워줄 alert
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            HStack {
                HStack(spacing: 20) {
                    HStack(alignment: .bottom, spacing: -15) {
                        // 사용자 프로필 이미지
                        if let image = userProfileImage { // 사용자 지정 이미지가 있을 때 (이미지 선택 완료했을 경우)
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 70, height: 70)  // 원의 크기 조절
                                .overlay(Circle().stroke(Color.gray03, lineWidth: 1))  // 원 테두리 추가
                        } else {
                            // 사용자 지정 이미지가 없을 때 기본 이미지로 설정
                            // TODO: 기본 이미지 파일 지정해서 넣기
                            Image("appIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 70, height: 70)
                                .overlay(Circle().stroke(Color.gray03, lineWidth: 1))
                        }
                        // 프로필 사진 수정 버튼
                        if userType == .user {
                            LibraryPhotosPicker(selectedPhotos: $selectedPhotos, maxSelectionCount: 1) { // 최대 1장
                                Image(systemName: "pencil.circle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 20, height: 20)
                                    .foregroundStyle(.gray01)
                            }
                            .onChange(of: selectedPhotos) { _ in
                                Task {
                                    do {
                                        try await updateImage()
                                    } catch {
                                        // 이미지 로드 실패 alert 띄워주기
                                        showAlert = true
                                    }
                                }
                            }
                            .tint(.mainBlack)
                            .alert(isPresented: $showAlert) {
                                Alert(title: Text("사진을 불러오는데 실패했어요\n다시 시도해주세요"),
                                      dismissButton: .default(Text("확인"), action: { showAlert = false }))
                            }
                        }
                    }
                    // 사용자 닉네임 표시
                    Text(userNickName)
                        .font(.medium18)
                    Spacer()
                    
                    if userType == .user {
                        NavigationLink {
                            ChangeUserNameView(userNickName: $userNickName)
                                .modifier(TabBarHidden())
                        } label: {
                            Text("닉네임 수정")
                                .font(.light14)
                                .foregroundStyle(.gray01)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
    }
    
    private func updateImage() async throws {
        guard let selectedPhoto = selectedPhotos.first else {
            return
        }
        do {
            guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else {
                throw PhotosPickerImageLoadingError.invalidImageData
            }
            userProfileImage = UIImage(data: data)
        } catch {
            throw PhotosPickerImageLoadingError.invalidImageData
        }
    }
}

#Preview {
    UserProfileView(userType: .otheruser)
}

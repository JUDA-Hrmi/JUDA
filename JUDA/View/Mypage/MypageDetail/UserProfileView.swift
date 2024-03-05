//
//  UserProfileView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/02/01.
//

import SwiftUI
import PhotosUI
import Kingfisher

enum UserType {
    case user, otheruser
}

// MARK: - 유저 프로필 (사진, 닉네임, 닉네임 수정)
struct UserProfileView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var postsViewModel: PostsViewModel
    @EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var myPageViewModel: MyPageViewModel
    @EnvironmentObject private var likedViewModel: LikedViewModel
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var selectedImage = UIImage()
    
    let userType: UserType
    let userName: String
    let userID: String
    let usedTo: WhereUsedPostGridContent

    private var profileImageURL: URL? {
        switch usedTo {
        case .postSearch:
            return searchPostsViewModel.postUserImages[userID]
        case .liked:
            return likedViewModel.postUserImages[userID]
        case .myPage:
            return myPageViewModel.postUserImages[userID]
        case .main:
            return mainViewModel.postUserImages[userID]
        default: // post 그 외
            return postsViewModel.postUserImages[userID]
        }
    }
    
    // 이미지 가져오다가 에러나면 띄워줄 alert
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            HStack {
                HStack(spacing: 20) {
                    HStack(alignment: .bottom, spacing: -15) {
                        // 사용자 프로필 이미지
                        if userType == .user,
                           let user = authService.currentUser { // 사용자 지정 이미지가 있을 때 (이미지 선택 완료했을 경우)
                            KFImage.url(user.profileURL)
                                .placeholder {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 70, height: 70)
                                }
                                .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
                                .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
                                .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
                                .fade(duration: 0.2) // 이미지 부드럽게 띄우기
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 70, height: 70)
                        } else if let profileImageURL = profileImageURL {
                            UserProfileKFImage(url: profileImageURL)
                        } else {
                            // 사용자 지정 이미지가 없을 때 기본 이미지로 설정
                            Image("defaultprofileimage")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 70, height: 70)
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
                    Text(userName)
                        .font(.medium18)
                    
                    Spacer()
                    // 닉네임 수정
                    if userType == .user {
                        NavigationLink(value: Route.ChangeUserName) {
                            Text("닉네임 수정")
                                .font(.regular14)
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
            guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else { return }
            guard let uiImage = UIImage(data: data) else { return }
            self.selectedImage = uiImage
            authService.uploadProfileImageToStorage(image: uiImage)
        } catch {
            throw PhotosPickerImageLoadingError.invalidImageData
        }
    }
}

// MARK: - UserProfileView 의 이미지 프로필에서 사용하는 KFImage
struct UserProfileKFImage: View {
    let url: URL
    
    var body: some View {
        KFImage.url(url)
            .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
            .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
            .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
            .fade(duration: 0.2) // 이미지 부드럽게 띄우기
            .resizable()
            .aspectRatio(contentMode: .fill)
            .clipShape(Circle())
            .frame(width: 70, height: 70)
    }
}

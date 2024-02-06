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
    
    let userType: UserType
    
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var userProfileImage: UIImage? // 사용자 프로필 이미지
    
//    @State private var isPickerPresented = false
    
    var body: some View {
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
                        .task(id: selectedPhotos) {
                            await updateImage()
                        }
//                        Image(systemName: "pencil.circle.fill")
//                            .resizable()
//                            .aspectRatio(contentMode: .fill)
//                            .frame(width: 20, height: 20)
//                            .foregroundStyle(.gray01)
//                            .onTapGesture {
//                                isPickerPresented = true
//                            }
//                            .photosPicker(isPresented: $isPickerPresented, selection: $selectedPhotos,
//                                          maxSelectionCount: 1, selectionBehavior: .default,
//                                          matching: .images, photoLibrary: .shared())
//                            .onChange(of: selectedPhotos) { _ in
//                                isPickerPresented = true
//                                if let top = UIViewController.topMost() {
//                                    let alertController = UIAlertController(title: "프로필 사진을\n선택한 사진으로 변경할까요?", message: "", preferredStyle: .alert)
//                                    alertController.addAction(
//                                        UIAlertAction(title: "변경하기", style: .default) { _ in
//                                            isPickerPresented = false
//                                            Task {
//                                                await updateImage()
//                                            }
//                                        }
//                                    )
//                                    alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
//                                    top.present(alertController, animated: true, completion: nil)
//                                }
//                            }
//                            .tint(.mainBlack)
                    }
                }
                // MARK: 사용자 닉네임 표시
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
    
    @MainActor
    private func updateImage() async {
        guard let selectedPhoto = selectedPhotos.first else {
            return
        }
        do {
            guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else {
                print("Error photo to data")
                return
            }
            userProfileImage = UIImage(data: data)
        } catch let error {
            print("Error loading image: \(error.localizedDescription)")
        }
    }
}

#Preview {
    UserProfileView(userType: .otheruser)
}

//extension UIViewController {
//    static func topMost(_ root: UIViewController? = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController) -> UIViewController? {
//        if let navigation = root as? UINavigationController {
//            return topMost(navigation.visibleViewController)
//        } else if let tabbar = root as? UITabBarController, let selected = tabbar.selectedViewController {
//            return topMost(selected)
//        } else if let presented = root?.presentedViewController {
//            return topMost(presented)
//        }
//        return root
//    }
//}

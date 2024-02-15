//
//  ProfileSettingView.swift
//  JUDA
//
//  Created by phang on 2/15/24.
//

import SwiftUI
import PhotosUI

// MARK: - 프로필 사진 및 정보 작성 뷰에서 사용될 focusField enum
enum ProfileSettingFocusField: Hashable {
    case name
    case birth
}

// MARK: - 성별 enum
enum Gender: String, CaseIterable {
    case male
    case female
    
    var koreanString: String {
        switch self {
        case .male: "남성"
        case .female: "여성"
        }
    }
}

// MARK: - 신규 유저의 경우, 프로필 사진 및 정보 작성 뷰
struct ProfileSettingView: View {
    @Environment(\.dismiss) private var dismiss
    
    @FocusState var focusedField: ProfileSettingFocusField?

    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var userProfileImage: UIImage? // 사용자 프로필 이미지
    
    @State private var name: String = ""
    @State private var birthDate: String = ""
    
    @State private var selectedGender: Gender?
    // 이미지 가져오다가 에러나면 띄워줄 alert
    @State private var isShowAlertDialog = false
    
    var nameReference: Bool {
        focusedField == .name && (name.count <= 1 || name.count > 10)
    }

    // 상위 뷰 체인지를 위함
    @Binding var viewType: TermsOrVerification
    
    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 40) {
                // 상단 바
                ZStack(alignment: .leading) {
                    // 뒤로가기
                    Button {
                        viewType = .TermsOfService
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.medium16)
                    }
                    // 타이틀
                    Text("프로필 설정")
                        .font(.medium16)
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 10)
                .foregroundStyle(.mainBlack)
                HStack(alignment: .lastTextBaseline, spacing: 20) {
                    // 프로필 사진 선택
                    ZStack(alignment: .bottomTrailing) {
                        // TODO: - 프로필 사진
                        if let image = userProfileImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 100, height: 100)
                                .overlay(Circle().stroke(Color.gray03, lineWidth: 1))
                        } else {
                            Image("appIcon")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .clipShape(Circle())
                                .frame(width: 100, height: 100)
                                .overlay(Circle().stroke(Color.gray03, lineWidth: 1))
                        }
                        LibraryPhotosPicker(selectedPhotos: $selectedPhotos, maxSelectionCount: 1) { // 최대 1장
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 25, height: 25)
                                .foregroundStyle(.gray01)
                        }
                        .onChange(of: selectedPhotos) { _ in
                            Task {
                                do {
                                    try await updateImage()
                                } catch {
                                    // 이미지 로드 실패 alert 띄워주기
                                    isShowAlertDialog = true
                                }
                            }
                        }
                        .tint(.mainBlack)
                    }
                    // 닉네임
                    VStack(alignment: .leading, spacing: 10) {
                        // Text
                        Text("닉네임")
                            .font(.semibold16)
                            .foregroundStyle(.mainBlack)
                        // 텍스트 필드
                        HStack {
                            // TODO: - 로그인 시, 이름으로 초기 설정
                            TextField("닉네임", text: $name)
                                .font(.medium16)
                                .foregroundStyle(.mainBlack)
                                .focused($focusedField, equals: .name)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled() // 자동 수정 비활성화
                            Spacer()
                            // 텍스트 한번에 지우는 xmark 버튼
                            if !name.isEmpty && focusedField == .name {
                                Button {
                                    name = ""
                                } label: {
                                    Image(systemName: "xmark")
                                }
                                .foregroundStyle(.gray01)
                            }
                        }
                        // 텍스트 필드 언더라인
                        Rectangle()
                            .fill(.gray02)
                            .frame(height: 1)
                        // 닉네임 만족 기준
                        Text("닉네임을 2자~10자 이내로 적어주세요.")
                            .font(.light14)
                            .foregroundStyle(nameReference ? .mainAccent01 : .clear)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                HStack(alignment: .bottom) {
                    // 생일
                    VStack(alignment: .leading, spacing: 10) {
                        // Text
                        Text("생년월일")
                            .font(.semibold16)
                            .foregroundStyle(.mainBlack)
                        // 텍스트 필드
                        TextField("ex: 930715", text: $birthDate)
                            .font(.medium16)
                            .foregroundStyle(.mainBlack)
                            .focused($focusedField, equals: .birth)
                            .keyboardType(.default)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled() // 자동 수정 비활성화
                        // 텍스트 필드 언더라인
                        Rectangle()
                            .fill(.gray02)
                            .frame(height: 1)
                    }
                    // 성별
                    HStack(alignment: .center, spacing: 10) {
                        ForEach(Gender.allCases, id: \.self) { gender in
                            ZStack {
                                Rectangle()
                                    .fill(.background)
                                    .frame(height: 40)
                                    .overlay {
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(selectedGender == gender ? .mainAccent03 : .gray02,
                                                    lineWidth: 1)
                                    }
                                Text(gender.koreanString)
                                    .font(selectedGender == gender ? .medium16 : .regular16)
                                    .foregroundStyle(selectedGender == gender ? .mainAccent03 : .mainBlack)
                            }
                            .onTapGesture {
                                selectedGender = gender
                            }
                        }
                    }
                }
                //
                Rectangle()
                    .fill(.background)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                // "완료" 버튼
                Button {
                    // TODO: - 생일, 성별 정보 수집 ( 서버 )
                    // TODO: NavigationPath 초기화 ( 메인 뷰로 이동 )
                } label: {
                    Text("완료")
                        .font(.medium20)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .tint(.mainAccent03)
                // 모든 정보 입력 시, 버튼 보이도록
                .disabled(name.isEmpty || birthDate.isEmpty || selectedGender == nil)
                .padding(.bottom, 10)
            }
            .padding(.horizontal, 20)
            // 키보드 숨기기
            .onTapGesture {
                focusedField = nil
            }
            // 생일 6글자 치면 끝
            .onChange(of: birthDate) { _ in
                if birthDate.count == 6 {
                    focusedField = nil
                }
            }
            //
            .onSubmit {
                switch focusedField {
                case .name:
                    focusedField = .birth
                default:
                    focusedField = nil
                }
            }
            if isShowAlertDialog {
                CustomDialog(type: .oneButton(
                    message: "사진을 불러오는데 실패했어요\n다시 시도해주세요",
                    buttonLabel: "확인",
                    action: {
                        isShowAlertDialog = false
                    })
                )
            }
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
    ProfileSettingView(viewType: .constant(.ProfileSetting))
}

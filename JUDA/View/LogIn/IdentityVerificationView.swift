//
//  IdentityVerificationView.swift
//  JUDA
//
//  Created by phang on 2/14/24.
//

import SwiftUI

// MARK: - 본인 인증 화면에서 사용될 focusField enum
enum VerificationFocusField: Hashable {
    case name
    case birthDate
    case genderNumber
    case phoneNumber
    case verificationNumber
}

// MARK: - 신규 회원, 본인 인증 화면
struct IdentityVerificationView: View {
    @Environment(\.dismiss) private var dismiss
    
    @FocusState var focusedField: VerificationFocusField?
    
    @State private var name: String = ""
    @State private var birthDate: String = ""
    @State private var genderNumber: String = ""
    @State private var phoneNumber: String = ""
    @State private var verificationNumber: String = ""
    @State private var sendVerificationNumber: Bool = false
    
    @State private var remainingTime: Int = 180
    @State private var timer: Timer? = nil
    // 상위 뷰 체인지를 위함
    @Binding var viewType: TermsOrVerification
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 30) {
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
                        Text("본인인증")
                            .font(.medium16)
                            .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 10)
                    .foregroundStyle(.mainBlack)
                    // 이름
                    VStack(alignment: .leading, spacing: 10) {
                        // 텍스트 필드
                        TextField("이름", text: $name)
                            .font(.medium16)
                            .foregroundStyle(.mainBlack)
                            .focused($focusedField, equals: .name)
                            .keyboardType(.default)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled() // 자동 수정 비활성화
                        // 텍스트 필드 언더라인
                        Rectangle()
                            .fill(.gray02)
                            .frame(height: 1)
                    }
                    // 주민번호
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            // 텍스트 필드 ( 생년월일 )
                            TextField("생년월일 (ex: 930715)", text: $birthDate)
                                .focused($focusedField, equals: .birthDate)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled() // 자동 수정 비활성화
                                .frame(width: (geo.size.width - 60) / 2)
                            Text(" - ")
                                .frame(width: 20)
                            HStack(alignment: .center, spacing: 0) {
                                // 텍스트 필드 ( 성별 )
                                TextField("●", text: $genderNumber)
                                    .focused($focusedField, equals: .genderNumber)
                                    .keyboardType(.numberPad)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled() // 자동 수정 비활성화
                                    .frame(width: 18)
                                Text("●●●●●●")
                            }
                        }
                        .font(.medium16)
                        .foregroundStyle(.mainBlack)
                        // 텍스트 필드 언더라인
                        Rectangle()
                            .fill(.gray02)
                            .frame(height: 1)
                    }
                    // 핸드폰 번호
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            // 텍스트 필드
                            TextField("핸드폰 번호 (- 제외)", text: $phoneNumber)
                                .font(.medium16)
                                .foregroundStyle(.mainBlack)
                                .focused($focusedField, equals: .phoneNumber)
                                .keyboardType(.numberPad)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled() // 자동 수정 비활성화
                            // 인증번호 전송 버튼
                            Button {
                                sendVerificationNumber = true
                                startTimer()
                                // TODO: - 인증번호 전송
                            } label: {
                                Text("인증번호 전송")
                                    .font(.medium14)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.mainAccent03)
                            .clipShape(.capsule)
                            // 텍스트 필드 다 채워야, 버튼 보이도록
                            .disabled((name.isEmpty || birthDate.isEmpty ||
                                       genderNumber.isEmpty || phoneNumber.isEmpty) &&
                                      phoneNumber.count == 11)
                        }
                        // 텍스트 필드 언더라인
                        Rectangle()
                            .fill(.gray02)
                            .frame(height: 1)
                    }
                    // 인증 번호 입력 텍스트 필드
                    if sendVerificationNumber {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center) {
                                // 텍스트 필드
                                TextField("인증번호", text: $verificationNumber)
                                    .font(.medium16)
                                    .foregroundStyle(.mainBlack)
                                    .focused($focusedField, equals: .verificationNumber)
                                    .textContentType(.oneTimeCode)
                                    .keyboardType(.numberPad)
                                    .textInputAutocapitalization(.never)
                                    .autocorrectionDisabled() // 자동 수정 비활성화
                                // 인증번호 남은 시간
                                Text("\(String(format: "%.2d", remainingTime / 60)):\(String(format: "%.2d", remainingTime % 60))")
                                    .font(.regular14)
                                    .foregroundStyle(.mainAccent03)
                            }
                            // 텍스트 필드 언더라인
                            Rectangle()
                                .fill(.gray02)
                                .frame(height: 1)
                        }
                    }
                    //
                    Rectangle()
                        .fill(.background)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    // 다음 버튼
                    Button {
                        // TODO: - 인증번호 맞는지 확인 ( 틀리면 alert ? )
                        // TODO: - 생일, 성별 정보 수집 ( 서버 )
                        // TODO: NavigationPath 초기화 ( 메인 뷰로 이동 )
                    } label: {
                        Text("본인인증 완료")
                            .font(.medium20)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 5)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.mainAccent03)
                    // 인증번호 입력 시, 버튼 보이도록
                    .disabled(verificationNumber.isEmpty)
                    .padding(.bottom, 10)
                }
                .padding(.horizontal, 20)
            }
            // 키보드 숨기기
            .onTapGesture {
                focusedField = nil
            }
            // 생일 6글자 치면 다음 텍필 이동
            .onChange(of: birthDate) { _ in
                if birthDate.count == 6 {
                    focusedField = .genderNumber
                }
            }
            // 주민번호 뒷부분 1글자 치면 다음 텍필 이동
            .onChange(of: genderNumber) { _ in
                if genderNumber.count == 1 {
                    focusedField = .phoneNumber
                }
            }
            // 핸드폰 번호 치면 텍필 해제
            .onChange(of: phoneNumber) { _ in
                if phoneNumber.count == 11 {
                    focusedField = nil
                }
            }
            // 엔터 키 입력 시, 각 focus 상태에 따라 focus 이동 및 해제
            .onSubmit {
                switch focusedField {
                case .name:
                    focusedField = .birthDate
                case .birthDate:
                    focusedField = .genderNumber
                case .genderNumber:
                    focusedField = .phoneNumber
                case .phoneNumber:
                    focusedField = .verificationNumber
                case .verificationNumber:
                    focusedField = nil
                default:
                    return
                }
            }
        }
    }
    
    // 인증번호 3분 시간 체크 타이머
    private func startTimer() {
        timer?.invalidate()  // 기존 타이머 중지
        // 1초마다 타이머 업데이트
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                // TODO: - 타이머 종료 시 동작
                timer?.invalidate()
                timer = nil
            }
        }
    }
}

#Preview {
    IdentityVerificationView(viewType: .constant(.IdentityVerification))
}

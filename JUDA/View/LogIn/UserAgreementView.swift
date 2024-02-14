//
//  UserAgreementView.swift
//  JUDA
//
//  Created by phang on 2/14/24.
//

import SwiftUI

// MARK: - 이용약관
struct TermsOfService: Hashable {
    let id = UUID()
    let essential: Bool
    let content: String
    var check: Bool
}

// MARK: - 신규 유저의 경우, 개인 정보 활용 동의 체크 
struct UserAgreementView: View {
    @Environment(\.dismiss) private var dismiss

    private let webViewurlList = ["https://bit.ly/HrmiService",
                                  "https://bit.ly/HrmiPrivacyPolicy",
                                  "https://bit.ly/HrmiLocationPolicy"]
    @State var isShowWebView: Bool = false

    @State private var termsOfServiceContents: [TermsOfService] = [
        TermsOfService(essential: true, content: "이용약관", check: false),
        TermsOfService(essential: true, content: "개인정보 수집 및 이용 안내", check: false),
        TermsOfService(essential: true, content: "제 3자 제공 동의", check: false),
        TermsOfService(essential: false, content: "알림 수신 동의", check: false),
    ]
    // 전체 동의 체크박스
    @State private var allChecked: Bool = false
    
    @State private var nextView: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 25) {
            ForEach(termsOfServiceContents.indices, id: \.self) { index in
                HStack(spacing: 5) {
                    // 체크 박스
                    CheckBox(isCheck: termsOfServiceContents[index].check)
                        .onTapGesture {
                            termsOfServiceContents[index].check.toggle()
                        }
                        .padding(.trailing, 5)
                    // 필수 or 선택
                    Text(termsOfServiceContents[index].essential ? "(필수)" : "(선택)")
                        .foregroundStyle(termsOfServiceContents[index].essential ? .mainBlack : .mainAccent04)
                    // 약관 명
                    Text(termsOfServiceContents[index].content)
                    //
                    Spacer()
                    // 알림 수신 동의 제외
                    if index != termsOfServiceContents.count - 1 {
                        // 약관 관련 페이지 이동
                        Button {
                            isShowWebView.toggle()
                        } label: {
                            Text("보기")
                                .font(.regular14)
                                .foregroundStyle(.gray01)
                        }
                        .fullScreenCover(isPresented: $isShowWebView) {
                            SafariView(url: URL(string: webViewurlList[index])!)
                        }
                    }
                }
                .font(.regular16)
            }
            //
            CustomDivider()
            HStack(alignment: .top, spacing: 10) {
                // 전체 동의
                CheckBox(isCheck: allChecked)
                    .onTapGesture {
                        allChecked.toggle()
                        termsOfServiceContents.indices.forEach { index in
                            termsOfServiceContents[index].check = allChecked
                        }
                    }
                VStack(alignment: .leading, spacing: 4) {
                    Text("전체 동의")
                        .font(.regular16)
                    HStack(alignment: .center, spacing: 4) {
                        Text("(선택)")
                            .foregroundStyle(.mainAccent04)
                        Text("알림 수신 동의를 포함하여 모두 동의합니다")
                    }
                    .font(.light12)
                }
            }
            //
            Spacer()
            Button {
                // TODO: - 약관 및 알림 동의 처리 ( 서버 )
                // TODO: NavigationLink - value 로 수정
                nextView = true
            } label: {
                Text("다음")
                    .font(.medium20)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
            }
            .buttonStyle(.borderedProminent)
            .tint(.mainAccent03)
            // 필수 약관 체크 되어야 버튼 보이도록
            .disabled(!termsOfServiceContents.filter { $0.essential }.allSatisfy { $0.check })
            .padding(.bottom, 10)
        }
        .padding([.top, .horizontal], 20)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
                .foregroundStyle(.mainBlack)
            }
            ToolbarItem(placement: .principal) {
                Text("이용약관")
                    .font(.medium16)
                    .foregroundStyle(.mainBlack)
            }
        }
        .navigationDestination(isPresented: $nextView) {
            IdentityVerificationView()
        }
    }
}

#Preview {
    UserAgreementView()
}

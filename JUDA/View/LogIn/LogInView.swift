//
//  LogInView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//


import SwiftUI
import AuthenticationServices

// MARK: - 로그인 화면
struct LogInView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        ZStack {
            VStack {
                //
                Spacer()
                // 로고 + 이름
                VStack(alignment: .center, spacing: 20) {
                    // 앱 아이콘
                    Image("appIcon")
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: 290)
                        .cornerRadius(10)
                    // 앱 이름
                    Text("주다 - JUDA")
                        .font(.semibold24)
                        .multilineTextAlignment(.center)
                }
                //
                Spacer()
                Spacer()
                // 로그인 버튼
                VStack(spacing: 30) {
                    // 애플 로그인
                    SignInWithAppleButton(.signIn) { request in
                        authService.nonce = authService.randomNonceString()
                        request.requestedScopes = [.email, .fullName]
                        request.nonce = authService.sha256(authService.nonce)
                    } onCompletion: { result in
                        switch result {
                        case .success(let user):
                            print("success")
                            guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                                print("Error with firebase")
                                return
                            }
                            authService.appleAuthenticate(credential: credential)
                        case  .failure(let error):
                            print("Fail - \(error.localizedDescription)")
                        }
                    }
                    .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
                    .frame(width: 300, height: 48)
                    // 구글 로그인
                    Image("Google")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                    // 카카오 로그인
                    Image("Kakao")
                        .resizable()
                        .frame(width: 300, height: 48)
                        .aspectRatio(contentMode: .fit)
                }
                Spacer()
                //
                Text("2024, 주다 - JUDA all rights reserved.\nPowered by PJ4T7_HrMi")
                    .font(.light12)
                    .multilineTextAlignment(.center)
            }
        }
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
        }
        // 로그인 완료 시, 뒤로 가기 ( 메인 뷰로 이동 )
        .onChange(of: authService.signInStatus) { newValue in
            if newValue == true {
                dismiss()
            }
        }
    }
}

#Preview {
    LogInView()
}

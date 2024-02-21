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
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject var colorScheme: SystemColorTheme
    
    @State private var nextView: Bool = false
    
    var body: some View {
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
            // 로그인 중 - progress
            if authService.signInButtonClicked == true {
                ProgressView()
                    .progressViewStyle(.circular)
            }
            //
            Spacer()
            // 로그인 버튼
            VStack(spacing: 30) {
                // 애플 로그인
                SignInWithAppleButton(.signIn) { request in
                    authService.handleSignInWithAppleRequest(request)
                } onCompletion: { result in
                    authService.handleSignInWithAppleCompletion(result)
                }
                .signInWithAppleButtonStyle(colorScheme.selectedColor == .light ? .black: (colorScheme.selectedColor == .dark ? .white : .black))
                .frame(width: 300, height: 48)
            }
            Spacer()
            
            Text("2024, 주다 - JUDA all rights reserved.\nPowered by PJ4T7_HrMi")
                .font(.thin12)
                .multilineTextAlignment(.center)
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
        // 로그인 완료 시 화면 이동
        .onChange(of: authService.signInStatus) { newValue in
            authService.signInButtonClicked = false
            if newValue == true {
                // 기존 유저의 경우, 뒤로 가기 ( 메인 뷰로 이동 )
                dismiss()
            }
        }
        .onChange(of: authService.isNewUser) { _ in
            authService.signInButtonClicked = false
            // 신규 유저의 경우, 이용약관 뷰 이동
            if authService.isNewUser == true {
                nextView = true
            }
        }
        .fullScreenCover(isPresented: $nextView) {
            TermsAndVerificationView()
        }
    }
}

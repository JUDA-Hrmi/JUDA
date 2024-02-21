//
//  SplashView.swift
//  JUDA
//
//  Created by phang on 2/17/24.
//

import SwiftUI

// MARK: - SplashView
struct SplashView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject var colorScheme: SystemColorTheme
    @Binding var isActive: Bool

    var body: some View {
        VStack {
            Text("Splash View")
        }
        .task {
            // 로그인이 되어있다면, 유저 정보 받아오기
            if authService.signInStatus == true {
                await authService.fetchUserData()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
                withAnimation {
                    self.isActive = false
                }
            }
        }
        // SettingView - 화면 모드 -> 선택한 옵션에 따라 배경색 변환
        .preferredColorScheme(colorScheme.selectedColor == .light ? .light : colorScheme.selectedColor == .dark ? .dark : .none)
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}

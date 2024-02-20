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
    @StateObject var colorScheme = BackgroundTheme()
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
        .preferredColorScheme(colorScheme.selectedColor)
    }
}

#Preview {
    SplashView(isActive: .constant(true))
}

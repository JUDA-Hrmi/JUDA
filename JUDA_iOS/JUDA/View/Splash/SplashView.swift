//
//  SplashView.swift
//  JUDA
//
//  Created by phang on 2/17/24.
//

import SwiftUI

// MARK: - SplashView
struct SplashView: View {
    @Environment (\.colorScheme) var systemColorScheme
    @ObservedObject private var splashViewModel = SplashViewModel()
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var colorScheme: SystemColorTheme
    @EnvironmentObject private var appViewModel: AppViewModel
    
    @Binding var isActive: Bool
    
    var body: some View {
        VStack() {
            Spacer()
            ZStack(alignment: .topLeading) {
                // 다크 모드
                if .dark == colorScheme.selectedColor ||
                    (colorScheme.selectedColor == nil && systemColorScheme == .dark) {
                    Image("JUDA_AppLogo_ver2_Dark")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    splashViewModel.configureWeatherImageView(forImages: splashViewModel.weatherImagesDark)
                  // 라이트 모드
                } else {
                    Image("JUDA_AppLogo_ver2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    splashViewModel.configureWeatherImageView(forImages: splashViewModel.weatherImagesLight)

                }
            }
            Text("JUDA")
                .font(.regular50)
            Spacer()
            Text("2024, 주다 - JUDA all rights reserved.\nPowered by PJ4T7_HrMi")
                .font(.thin12)
                .multilineTextAlignment(.center)
        }
        // MainView 에서 보여줄 데이터
        .task {
            await withTaskGroup(of: Void.self) { taskGroup in
                // 인기 술 미리 받아오기
                taskGroup.addTask { await mainViewModel.getHottestDrinks() }
                // 인기 술상 미리 받아오기
                taskGroup.addTask { await mainViewModel.getHottestPosts() }
                // 앱 시작 시, 유저 데이터 받아오기
                taskGroup.addTask {
                    if await authViewModel.signInStatus {
                        await authViewModel.getCurrentUser()
                    }
                }
                // 로그인 + 위치 정보 받았을 때, 날씨 & 음식 + 술 받아오기
                taskGroup.addTask {
                    if await authViewModel.signInStatus,
                       let location = await appViewModel.locationManager.location {
                        await mainViewModel.getWeatherAndAIResponse(location: location)
                    }
                }
            }
            // Splash View 종료
            withAnimation {
                self.isActive = false
            }
        }
        // SettingView - 화면 모드 -> 선택한 옵션에 따라 배경색 변환
        .preferredColorScheme(colorScheme.selectedColor == .light ? .light : colorScheme.selectedColor == .dark ? .dark : nil)
    }
}

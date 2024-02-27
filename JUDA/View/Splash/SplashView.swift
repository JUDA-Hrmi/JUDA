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
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject var colorScheme: SystemColorTheme
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var aiViewModel: AiViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var searchPostsViewModel: SearchPostsViewModel
    
    @Binding var isActive: Bool
    @State private var imageIndex: Int = 0
    
    private let weatherImagesLight = ["cloud_light", "cloudySun_light", "snow_light", "rain_light"]
    private let weatherImagesDark = ["cloud_dark", "cloudySun_dark", "snow_dark", "rain_dark"]

    private func switchWeatherImage(list: [String]) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            imageIndex = (imageIndex + 1) % list.count
        }
        // .common -> 뷰 소멸 시 타이머 멈춤
        RunLoop.current.add(timer, forMode: .common)
    }
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
                    Image(weatherImagesDark[imageIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(x: 40, y: 30)
                        .onAppear {
                            switchWeatherImage(list: weatherImagesDark)
                        }
                  // 라이트 모드
                } else {
                    Image("JUDA_AppLogo_ver2")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300)
                    Image(weatherImagesLight[imageIndex])
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .offset(x: 40, y: 30)
                        .onAppear {
                            switchWeatherImage(list: weatherImagesLight)
                        }
                }
            }
            Text("JUDA")
                .font(.regular50)
            Spacer()
            Text("2024, 주다 - JUDA all rights reserved.\nPowered by PJ4T7_HrMi")
                .font(.thin12)
                .multilineTextAlignment(.center)
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
        // MainView 에서 보여줄 데이터
        .task {
            await withTaskGroup(of: Void.self) { taskGroup in
                // 인기 술 미리 받아오기
                taskGroup.addTask { await mainViewModel.getHottestDrinks() }
                // 인기 술상 미리 받아오기
                taskGroup.addTask { await mainViewModel.getHottestPosts() }
                //
                taskGroup.addTask { await searchPostsViewModel.fetchPosts() }
            }
        }
        .onAppear {
            if weatherViewModel.shouldFetchWeather() && authService.signInStatus {
                
                if let location = appViewModel.locationManager.location {
                    weatherViewModel.isLoading = true
                    Task {
                        do {
                            // Fetch weather data
                            let weatherData = try await weatherViewModel.fetchWeather(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                            weatherViewModel.weather = weatherData
                            // Request
                            aiViewModel.respond = try await aiViewModel.request(prompt: "Please recommend snacks and drinks that go well with this weather. Please refer to the below list behind you for the sake of snacks. Please recommend one each for snacks and drinks. When printing snacks and drinks \(String(describing: weatherViewModel.weather?.main)) ---dish List: \(aiViewModel.snacks) ---drink List:\(aiViewModel.drinkNames)")
                            weatherViewModel.lastAPICallTimestamp = Date()
                        } catch {
                            print("Error: \(error)")
                        }
                        weatherViewModel.isLoading = false
                    }
                }
            }
        }
        // SettingView - 화면 모드 -> 선택한 옵션에 따라 배경색 변환
        .preferredColorScheme(colorScheme.selectedColor == .light ? .light : colorScheme.selectedColor == .dark ? .dark : nil)
    }
}

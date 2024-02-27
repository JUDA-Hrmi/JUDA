//
//  WeatherAndFood.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 날씨 & 술 + 음식 추천 뷰
struct WeatherAndFood: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @EnvironmentObject var aiViewModel: AiViewModel
   
    var body: some View {
        VStack(alignment: authService.signInStatus ? .leading : .center, spacing: 10) {
            VStack(alignment: authService.signInStatus ? .leading : .center) {
                // 날씨 애니메이션 뷰
                if let weather = weatherViewModel.weather {
                    LottieView(jsonName: weatherViewModel.getAnimationName(for: weather.main))
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: 180, height: 180)
                    if authService.signInStatus {
                        Text(weatherViewModel.getKoreanWeatherDescription(for: weather.main))
                            .font(.semibold18)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                } else {
                    LottieView(jsonName: "Sun")
                        .frame(width: 180, height: 180)
                        .aspectRatio(1.0, contentMode: .fit)
                }
            }
            .frame(maxWidth: .infinity, alignment: authService.signInStatus ? .leading : .center)
            
            VStack(alignment: authService.signInStatus ? .leading : .center) {
                if weatherViewModel.isLoading {
                    ProgressView()
                } else {
                    if authService.signInStatus {
                        VStack(alignment: .leading) {
                            Text(aiViewModel.respond)
                                .foregroundStyle(.mainAccent03)
                            Text("한 잔 어때요?")
                        }
                    } else {
                        VStack(alignment: .center, spacing: 20) {
                            VStack {
                                Text("오늘의 날씨에 맞는")
                                HStack {
                                    Text("술과 안주")
                                        .foregroundStyle(.mainAccent03)
                                    Text("를 추천 받고 싶다면?")
                                }
                            }
                            .font(.medium18)
                            NavigationLink(value: Route.Login) {
                                HStack(alignment: .center) {
                                    Text("로그인 하러가기")
                                        .font(.semibold16)
                                        .foregroundStyle(.mainAccent03)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(.mainAccent03.opacity(0.2))
                                .clipShape(.rect(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: authService.signInStatus ? .leading : .center)
        }
        .font(authService.signInStatus ? .bold28 : .bold22)
        .padding(.horizontal, 20)
    }
    

}

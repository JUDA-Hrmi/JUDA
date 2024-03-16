//
//  SplashViewModel.swift
//  JUDA
//
//  Created by phang on 3/11/24.
//

import SwiftUI

// MARK: - Splash View 에서만 사용
final class SplashViewModel: ObservableObject {
    @Published var imageIndex: Int = 0
    let weatherImagesLight = [
        "cloud_light", "cloudySun_light", "snow_light", "rain_light"
    ]
    let weatherImagesDark = [
        "cloud_dark", "cloudySun_dark", "snow_dark", "rain_dark"
    ]
    
    // SplashView 에서 앱 로고에 날씨 이모지 뷰 설정
    func configureWeatherImageView(forImages images: [String]) -> some View {
        Image(images[imageIndex])
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .offset(x: 40, y: 30)
            .onAppear {
                self.switchWeatherImage(list: images)
            }
    }
    
    // SplashView 에서 앱 로고에 날씨 이모지 변화시키는 메서드
    private func switchWeatherImage(list: [String]) {
        let timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            self.imageIndex = (self.imageIndex + 1) % list.count
        }
        // .common -> 뷰 소멸 시 타이머 멈춤
        RunLoop.current.add(timer, forMode: .common)
    }
}

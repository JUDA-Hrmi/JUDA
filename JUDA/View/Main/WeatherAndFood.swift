//
//  WeatherAndFood.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 날씨 & 술 + 음식 추천 뷰
struct WeatherAndFood: View {
    @Binding var isLoggedIn: Bool
    let food: [String] = ["해물파전", "안주"]
    let drink: [String] = ["막걸리", "술"]
    
    var body: some View {
        //        LottieView(jsonName: "Sun")
        //            .frame(height: 200)
        
        VStack(alignment: .center, spacing: 10) {
            // TODO: - 로티 애니메이션으로 대체
            Image("rain")
                .resizable()
				.aspectRatio(1.0, contentMode: .fill)
                .frame(width: 200, height: 200)
            // 날씨
            VStack(alignment: .center, spacing: 10) {
                // TODO: - 날씨에 맞는 텍스트로 들어가도록 수정
                Text(isLoggedIn ? "오늘은 비가 와요" : "오늘의 날씨와 어울리는")
                    .multilineTextAlignment(.leading)
                // 텍스트
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(isLoggedIn ? food[0] : food[1])
                        .foregroundColor(.mainAccent02)
                    Text(isLoggedIn ? " + " : "와 ")
                    Text(isLoggedIn ? drink[0] : drink[1])
                        .foregroundColor(.mainAccent02)
                    Text(isLoggedIn ? "한 잔 어때요?" : "조합을 확인하세요")
                }
            }
            .font(.bold22)
        }
    }
}

//
//  WeatherAndFood.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 날씨 + 메뉴 추천 뷰
struct WeatherAndFood: View {
    @Binding var isLoggedIn: Bool
    let food: [String] = ["해물파전", "안주"]
    let sul: [String] = ["막걸리", "술"]
    
    var body: some View {
        //        LottieView(jsonName: "Sun")
        //            .frame(height: 200)
        
        VStack(alignment: .center, spacing: 10) {
            Image("rain")
                .resizable()
				.aspectRatio(1.0, contentMode: .fill)
                .frame(width: 200, height: 200)
            
            VStack(alignment: .center, spacing: 10) {
                Text(isLoggedIn ? "오늘은 비가 와요" : "오늘의 날씨와 어울리는")
                    .multilineTextAlignment(.leading)
                
                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(isLoggedIn ? food[0] : food[1])
                        .foregroundColor(.mainAccent02)
                    Text(isLoggedIn ? " + " : "와 ")
                    Text(isLoggedIn ? sul[0] : sul[1])
                        .foregroundColor(.mainAccent02)
                    Text(isLoggedIn ? "한 잔 어때요?" : "조합을 확인하세요")
                }
            }
            .font(.bold22)
        }
    }
}

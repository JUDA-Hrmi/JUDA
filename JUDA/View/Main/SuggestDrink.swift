//
//  SuggestDrink.swift
//  JUDA
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 오늘의 추천 술
struct SuggestDrink: View {
    @Binding var isLoggedIn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            VStack(alignment:.leading, spacing: 10) {
                Text("오늘의 추천 술")
                    .font(.semibold18)
				// 술 이미지 + 이름
                TodayDrinkRecommended(isLoggedIn: $isLoggedIn)
                    .opacity(isLoggedIn ? 1.0 : 0.8)
                    .blur(radius: isLoggedIn ? 0 : 3)
            }
            .padding(.top,30)

        }
    }
}

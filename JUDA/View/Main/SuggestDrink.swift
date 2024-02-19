//
//  SuggestDrink.swift
//  JUDA
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 오늘의 추천 술
struct SuggestDrink: View {
    @EnvironmentObject private var authService: AuthService
    
    var body: some View {
        VStack(alignment:.leading, spacing: 10) {
            Text("오늘의 추천 술")
                .font(.semibold18)
            // 술 이미지 + 이름
            TodayDrinkRecommended()
                .opacity(authService.signInStatus ? 1.0 : 0.8)
                .blur(radius: authService.signInStatus ? 0 : 3)
        }
    }
}

//
//  WellMatched.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 잘 어울리는 음식
struct WellMatched: View {
    // UITest - 추천 받은 음식 3가지
    private let sampleData = DrinkDummyData.sample
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Well Matched
            Text("잘 어울리는 음식")
                .font(.semibold18)
            // 추천 받은 음식
            HStack(alignment: .center, spacing: 16) {
                ForEach(sampleData.wellMatchedFoods, id: \.self) { food in
                    Text(food)
                        .font(.regular16)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    WellMatched()
}

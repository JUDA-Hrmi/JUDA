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
    let wellMatched: [String]?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Well Matched
            HStack(alignment: .lastTextBaseline, spacing: 10) {
                Text("잘 어울리는 음식")
                    .font(.semibold18)
                Text("AI 추천 ✨")
                    .font(.semibold16)
                    .foregroundStyle(.mainAccent05)
            }
            // 추천 받은 음식
            HStack(alignment: .center, spacing: 16) {
                ForEach(wellMatched ?? ["-"], id: \.self) { food in
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
    WellMatched(wellMatched: ["해산물 파스타", "로스트 치킨", "회"])
}

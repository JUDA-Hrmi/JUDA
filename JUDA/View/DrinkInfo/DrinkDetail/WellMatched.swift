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
    @EnvironmentObject var aiWellMatchViewModel: AiWellMatchViewModel
    let drink = [
        "하이네켄",
        "막걸리"
    ]
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
                Text(aiWellMatchViewModel.respond)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onAppear {
            Task {
                do {
                    try await aiWellMatchViewModel.request(prompt: "Please recommend 3 foods that go well with you. Only food except drinks. List below --- Beverages List: \(drink)")
                } catch {
                    print("Error fetching recommendations: \(error)")
                }
            }
        }
    }
}

#Preview {
    WellMatched()
}

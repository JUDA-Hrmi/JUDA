//
//  WellMatched.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// TODO: - 실제 데이터와 연동 작업 필요 -> merge 이후 수정 필요
struct WellMatched: View {
    @EnvironmentObject var aiWellMatchViewModel: AiWellMatchViewModel
    @State private var isLoading = false
    let wellMatched: [String]?
    let windowWidth: CGFloat
    let drinkName: String
    let drinkCategory: String
    
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
            
            if isLoading {
                HStack {
                    CircularLoaderView(size: 16)
                }
                .frame(height: 20)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // 추천 받은 음식
                ForEach(TagHandler.getRows(tags: aiWellMatchViewModel.respond
                    .split(separator: ", ").map { String($0) },
                                           spacing: 14,
                                           fontSize: 16,
                                           windowWidth: windowWidth,
                                           tagString: ""), id: \.self) { row in
                    HStack(spacing: 14) {
                        ForEach(row, id: \.self) { value in
                            Text(value)
                                .font(.regular16)
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onAppear {
            isLoading = true
            Task {
                do {
                     aiWellMatchViewModel.fetchRecommendationsIfNeeded(prompt: "Please recommend three foods that go well with drinks. Only food except drinks. List below --- Beverages List: \(drinkName)")
                }
            }
            isLoading = false
        }
    }
    
}

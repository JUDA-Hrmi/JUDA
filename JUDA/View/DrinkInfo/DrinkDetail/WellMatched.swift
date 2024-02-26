//
//  WellMatched.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

struct WellMatched: View {
    @EnvironmentObject var aiWellMatchViewModel: AiWellMatchViewModel
    @ObservedObject var recommend = Recommend.shared
    @State private var lastAPICallTimestamp: Date? = nil
    @State private var isLoading = false
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
            if isLoading {
                ProgressView()
            } else {
                HStack(alignment: .center, spacing: 16) {
                    Text(aiWellMatchViewModel.respond)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .onAppear {
            Task {
                if fetchTimeInterval() {
                    do {
                        isLoading = true
                        await recommend.fetchDrinks()
                        aiWellMatchViewModel.respond = try await aiWellMatchViewModel.request(prompt: "Please recommend three foods that go well with drinks. Only food except drinks. List below --- Beverages List: \(recommend.recommend)")
                        print("\(aiWellMatchViewModel.respond)")
                        print("\(recommend.recommend)")
                        lastAPICallTimestamp = Date()
                    } catch {
                        print("Error fetching recommendations: \(error)")
                    }
                }
                isLoading = false
            }
            print("onappear call")
        }
        
    }
    
    private func fetchTimeInterval() -> Bool {
        guard let lastTimestamp = lastAPICallTimestamp else {
            return true
        }
        
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastTimestamp)
        let minimumTimeDifference: TimeInterval = 300
        
        return timeDifference >= minimumTimeDifference
    }
    
}



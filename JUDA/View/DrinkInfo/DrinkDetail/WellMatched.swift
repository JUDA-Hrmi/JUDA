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
    @ObservedObject var recommend = Recommend.shared
    @State private var lastAPICallTimestamp: Date? = nil
    @State private var isLoading = false
    let wellMatched: [String]?
    let windowWidth: CGFloat

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
                ProgressView()
            } else {
                HStack(alignment: .center, spacing: 16) {
                    // 추천 받은 음식
                    Text(aiWellMatchViewModel.respond)
            // 추천 받은 음식
//            ForEach(TagHandler.getRows(tags: wellMatched ?? [],
//                                       spacing: 10,
//                                       fontSize: 16,
//                                       windowWidth: windowWidth,
//                                       tagString: ""), id: \.self) { row in
//                HStack(spacing: 10) {
//                    ForEach(row, id: \.self) { value in
//                        Text(value)
//                            .font(.regular16)
//                    }
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

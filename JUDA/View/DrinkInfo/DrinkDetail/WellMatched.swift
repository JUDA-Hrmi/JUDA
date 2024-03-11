//
//  WellMatched.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

struct WellMatched: View {
    @EnvironmentObject var drinkViewModel: DrinkViewModel
    @State private var respond: [String] = []
    @State private var isLoading: Bool = false
    let windowWidth: CGFloat
    let drinkName: String
    
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
            
            if self.isLoading {
                HStack {
                    CircularLoaderView(size: 16)
                }
                .frame(height: 20)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                // 추천 받은 음식
                ForEach(TagHandler.getRows(tags: self.respond,
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
        .task {
            self.isLoading = true
            self.respond = await drinkViewModel
                .getFoodRecommendationsToOpenAI(drinkName: drinkName)
                .split(separator: ", ")
                .map { String($0) }
            self.isLoading = false
        }
    }
    
}

//
//  WellMatched.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

struct WellMatched: View {
    @EnvironmentObject var aiWellMatchViewModel: AiWellMatchViewModel
    let drink = [
        "하이네켄",
        "막걸리",
        "진로 소주",
        "발베니",
        "맥켈란"
    ]
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("Well Matched")
                
                Text(aiWellMatchViewModel.respond)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
        }
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

//
//  WellMatched.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

struct WellMatched: View {
    // UITest - 추천 받은 음식 3가지
    private let sampleData = DrinkDummyData.sample
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Well Matched
            // TODO: 추후 NameSpace 로 이동하면 좋을 String 값
            Text("Well Matched")
                .font(.semibold18)
            // 추천 받은 음식
            HStack(alignment: .center, spacing: 20) {
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

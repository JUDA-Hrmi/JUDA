//
//  TastingNotes.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

struct TastingNotes: View {
    // UITest - Drink Detail DummyData
    private let sampleData = DrinkDummyData.sample
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Tasting Notes
            // TODO: 추후 NameSpace 로 이동하면 좋을 String 값
            Text("향 / 맛 / 여운")
                .font(.semibold18)
            // Aroma, Taste, Finish
            ForEach(sampleData.tastingNotesList, id: \.self) { title in
                // 각 row
                HStack(alignment: .center, spacing: 30) {
                    // Aroma, Taste, Finish (타이틀)
                    Text(title)
                        .font(.medium16)
                        .frame(width: 50, alignment: .leading)
                    // 세부 내용
                    HStack(alignment: .center, spacing: 6) {
                        Text(sampleData.tastingNotes[title]?.joined(separator: ", ") ?? "-")
                            .font(.regular16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    TastingNotes()
}

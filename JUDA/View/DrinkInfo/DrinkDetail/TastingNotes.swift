//
//  TastingNotes.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 향 / 맛 / 여운
struct TastingNotes: View {
    // UITest - Drink Detail DummyData
    let aroma: [String]?
    let taste: [String]?
    let finish: [String]?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Tasting Notes
            Text("향 / 맛 / 여운")
                .font(.semibold18)
            // Aroma
            TastingNotesContent(title: "Aroma", content: aroma)
            // Taste
            TastingNotesContent(title: "Taste", content: taste)
            // Finish
            TastingNotesContent(title: "Finish", content: finish)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - 향 / 맛 / 여운
struct TastingNotesContent: View {
    let title: String
    let content: [String]?
    
    var body: some View {
        HStack(alignment: .center, spacing: 30) {
            Text(title)
                .font(.medium16)
                .frame(width: 50, alignment: .leading)
            // 세부 내용 - 향 / 맛 / 여운
            Text(content?.joined(separator: ", ") ?? "-")
                .font(.regular16)
        }
    }
}

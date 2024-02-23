//
//  WellMatched.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 잘 어울리는 음식
struct WellMatched: View {
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
            // 추천 받은 음식
            ForEach(TagHandler.getRows(tags: wellMatched ?? [],
                                       spacing: 10,
                                       fontSize: 16,
                                       windowWidth: windowWidth,
                                       tagString: ""), id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { value in
                        Text(value)
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

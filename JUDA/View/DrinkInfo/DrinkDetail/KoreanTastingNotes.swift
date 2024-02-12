//
//  KoreanTastingNotes.swift
//  JUDA
//
//  Created by phang on 2/12/24.
//

import SwiftUI

// MARK: - 단맛 / 신맛 / 청량 / 바디 / 탄산
struct KoreanTastingNotes: View {
    // UITest - Drink Detail DummyData
    let sweet: Int?
    let sour: Int?
    let refresh: Int?
    let bodyFeel: Int?
    let carbonated: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 단맛 / 신맛 / 청량 / 바디 / 탄산
            KoreanTastingNotesContent(title: "단맛", value: sweet)
            KoreanTastingNotesContent(title: "신맛", value: sour)
            KoreanTastingNotesContent(title: "청량감", value: refresh)
            KoreanTastingNotesContent(title: "바디감", value: bodyFeel)
            KoreanTastingNotesContent(title: "탄산", value: carbonated)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - 단맛 / 신맛 / 청량 / 바디 / 탄산 Row
struct KoreanTastingNotesContent: View {
    let title: String
    let value: Int?
    
    var body: some View {
        HStack(alignment: .center, spacing: 20) {
            Text(title)
                .font(.medium16)
                .frame(width: 50, alignment: .leading)
            // 세부 내용 - 단맛 / 신맛 / 청량 / 바디 / 탄산
            Rectangle()
                .fill(.mainAccent05.opacity(0.8))
                .frame(width: 30 * CGFloat(integerLiteral: value ?? 0), height: 12)
        }
    }
}

// MARK: - 재료 화면 부분
struct DrinkMaterial: View {
    let material: [String]
    let windowWidth: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("원재료")
                .font(.semibold18)
            ForEach(TagHandler.getRows(tags: material,
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

#Preview {
    KoreanTastingNotes(sweet: 2, sour: 3, refresh: 0, bodyFeel: nil, carbonated: 1)
}

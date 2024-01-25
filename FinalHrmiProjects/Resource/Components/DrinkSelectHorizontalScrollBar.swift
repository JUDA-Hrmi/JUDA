//
//  DrinkSelectHorizontalScrollBar.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/25/24.
//

import SwiftUI

struct DrinkSelectHorizontalScrollBar: View {
    // UITest - Drink 종류 DummyData
    private let typesOfDrink = [
        "전체", "우리술", "맥주", "위스키", "와인", "브랜디", "리큐르", "럼", "사케", "기타"
    ]
    // UITest - Drink 종류 DummyData
    @State private var selectedDrinkIndex = 0
    
    var body: some View {
        // 가로 스크롤
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: 20) {
                ForEach(0..<typesOfDrink.count, id: \.self) { index in
                    // 술 종류
                    Text(typesOfDrink[index])
                        .font(index == selectedDrinkIndex ? .semibold16 : .medium16)
                        .foregroundStyle(index == selectedDrinkIndex ? .mainBlack : .gray01)
                        .onTapGesture {
                            selectedDrinkIndex = index
                        }
                }
            }
        }
        // 스크롤 인디케이터 X
        .scrollIndicators(.hidden)
        .padding(20)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DrinkSelectHorizontalScrollBar()
}

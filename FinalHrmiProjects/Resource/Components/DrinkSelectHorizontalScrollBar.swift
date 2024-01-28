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
    @Binding var selectedDrinkTypeIndex: Int
    @Namespace private var animationWithDrinkType
    
    var body: some View {
        // 가로 스크롤
        ScrollView(.horizontal) {
            HStack(alignment: .center, spacing: 20) {
                ForEach(0..<typesOfDrink.count, id: \.self) { index in
                    // 술 종류
                    Text(typesOfDrink[index])
                        .font(index == selectedDrinkTypeIndex ? .semibold16 : .medium16)
                        .foregroundStyle(index == selectedDrinkTypeIndex ? .mainBlack : .gray01)
                        .onTapGesture {
                            selectedDrinkTypeIndex = index
                        }
                        .id(index)
                        .overlay(alignment: .bottom) {
                            // 전환 애니메이션 사용을 위한 장치
                            if selectedDrinkTypeIndex == index {
                                Rectangle()
                                    .matchedGeometryEffect(id: "selectDrinkType", in: animationWithDrinkType)
                                    .frame(height: 0)
                            }
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
    DrinkSelectHorizontalScrollBar(selectedDrinkTypeIndex: .constant(0))
}

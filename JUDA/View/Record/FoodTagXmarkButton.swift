//
//  FoodTagXmarkButton.swift
//  JUDA
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// MARK: - "X 음식태그" 형태를 가진 버튼
struct FoodTagXmarkButton: View {
    @EnvironmentObject private var recordViewModel: RecordViewModel
    // 음식 태그 이름
    let foodTag: String
    
    var body: some View {
        Button {
            // 버튼 클릭 시, foodTag 삭제
            recordViewModel.foodTags.removeAll(where: { $0 == foodTag })
        } label : {
            HStack(spacing: 2) {
                Image(systemName: "xmark")
                    .font(.regular14)
                    .foregroundStyle(.mainAccent04)
                Text(foodTag)
                    .font(.semibold14)
                    .foregroundStyle(Color.mainAccent04)
            }
        }
    }
}

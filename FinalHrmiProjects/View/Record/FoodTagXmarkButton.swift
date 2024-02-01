//
//  FoodTagXmarkButton.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// "X 음식태그" 형태를 가진 버튼
struct FoodTagXmarkButton: View {
    // 추가된 음식 태그 배열
    @Binding var foodTags: [FoodTag]
    // 음식 태그 이름
    let foodTag: FoodTag
    
    var body: some View {
        Button {
            // 버튼 클릭 시, foodTag 삭제
            foodTags.removeAll(where: { $0.id == foodTag.id })
        } label : {
            HStack(spacing: 2) {
                Image(systemName: "xmark")
                    .font(.regular14)
                    .foregroundStyle(.mainAccent04)
                // MARK: 태그 보여주는 순서 고민
                Text("\(foodTag.name)")
                    .font(.semibold14)
                    .foregroundStyle(Color.mainAccent04)
            }
        }
    }
}


//#Preview {
//    FoodTagXmarkButton()
//}

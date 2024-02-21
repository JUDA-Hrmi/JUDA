//
//  FoodTagVertical.swift
//  JUDA
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// MARK: - 추가된 음식 태그를 보여주는 부분
struct FoodTagVertical: View {
    @EnvironmentObject private var recordVM: RecordViewModel
    // 태그 결과를 보여주는 이차원 배열
    @State private var foodTagRows: [[String]] = []
        
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 15) {
            ForEach(foodTagRows, id: \.self) { row in
                HStack(spacing: 20) {
                    ForEach(row, id: \.self) { tag in
                        // "X 음식태그" 형태를 가진 버튼
                        FoodTagXmarkButton(foodTag: tag)
                    }
                }
            }
        }
        .padding(.vertical, 10)
        .frame(width: recordVM.windowWidth, alignment: .leading)
        // 음식 태그 배열에 변경사항이 있을 때마다 width에 맞게 2차원 배열로 매핑
        .onChange(of: recordVM.foodTags) { _ in
            foodTagRows = TagHandler.getRows(tags: recordVM.foodTags, spacing: 35, fontSize: 14, windowWidth: recordVM.windowWidth)
        }
    }
}

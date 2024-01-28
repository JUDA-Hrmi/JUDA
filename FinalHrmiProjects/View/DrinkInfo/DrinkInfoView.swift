//
//  DrinkInfoView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct DrinkInfoView: View {
    private let optionNameList = ["인기순", "도수 높은 순", "도수 낮은 순", "가격 높은 순", "가격 낮은 순"]
    @State private var isShowingSheet: Bool = false
    @State private var selectedSortingOption: String = "인기순"
    // 세그먼트 선택 - isGridView ? 그리드 뷰 : 리스트 뷰
    @State private var isGridView = true
    
    var body: some View {
        NavigationStack {
            ZStack {
                VStack(spacing: 0) {
                    // 검색 창
                    SearchBar()
                    // 술 종류 가로 스크롤
                    // TODO: 각 탭의 결과에 맞춰 보여줄 리스트 변경 필요
                    DrinkSelectHorizontalScrollBar()
                    // 세그먼트 + 필터링
                    DrinkInfoSegment(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet, isGridView: $isGridView)
                    // 그리드
                    if isGridView {
                        DrinkInfoGrid()
                    } else {
                        DrinkInfoList()
                    }
                }
                // DrinkInfoSegment 클릭 시 띄워지는 CustomSheet뷰
                EnabledBottomSheetView(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
            }
        }
    }
}

#Preview {
    DrinkInfoView()
}

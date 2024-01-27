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
    // 술 그리드 셀 2개 column
    private let columns: [GridItem] = [GridItem(.flexible()), GridItem(.flexible())]
    
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
                    // 세로 스크롤
                    ScrollView {
                        if isGridView {
                            // 그리드
                            LazyVGrid(columns: columns, spacing: 10) {
                                // TODO: 현재 더미데이터 10개를 보여주지만, 데이터 들어온 리스트로 ForEach 돌릴 예정
                                ForEach(0..<10, id: \.self) { _ in
                                    // TODO: 추후에 네비게이션으로 해당 술의 Detail 로 이동 연결
                                    DrinkGridCell()
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                        } else {
                            // 리스트
                            LazyVStack(spacing: 0) {
                                // TODO: 현재 더미데이터 10개를 보여주지만, 데이터 들어온 리스트로 ForEach 돌릴 예정
                                ForEach(0..<10, id: \.self) { _ in
                                    // TODO: 추후에 네비게이션으로 해당 술의 Detail 로 이동 연결
                                    DrinkListCell()
                                }
                            }
                        }
                    }
                    // 스크롤 인디케이터 X
                    .scrollIndicators(.hidden)
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

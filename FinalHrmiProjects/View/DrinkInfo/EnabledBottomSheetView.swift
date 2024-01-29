//
//  EnabledBottomSheetView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/27.
//

import SwiftUI

// MARK: - CustomSortingButton 클릭 시 띄워지는 CustomBottomSheet뷰
struct EnabledBottomSheetView: View {
    let optionNameList: [String] // 정렬옵션 이름이 담겨진 리스트
    
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    @Binding var headText: String
    
    var body: some View {
        ZStack {
            // 정렬 옵션 클릭 유무에 따른 뒷배경 블러 효과 쌓기
            Color.black.opacity(0.3)
                .opacity(isShowingSheet ? 1 : 0)
                .onTapGesture {
                    isShowingSheet.toggle()
                }
            // 정렬 옵션 클릭 -> CustomBottomSheet 올라옴
            if isShowingSheet {
                CustomBottomSheet($isShowingSheet, $headText, height: 300) {
                    SortingOptionsList(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
                }
            }
        }
        .ignoresSafeArea(.all)
        .animation(.interactiveSpring(), value: isShowingSheet)
    }
}

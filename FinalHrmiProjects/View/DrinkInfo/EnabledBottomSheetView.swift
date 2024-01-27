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
    
    var body: some View {
        ZStack {
            // 정렬 옵션 클릭 유무에 따른 뒷배경 블러 효과 쌓기
            Color.black.opacity(0.1)
                .opacity(isShowingSheet ? 1 : 0)
                .onTapGesture {
                    isShowingSheet.toggle()
                }
            // 정렬 옵션 클릭 -> CustomBottomSheet 올라옴
            if isShowingSheet {
                CustomBottomSheet($isShowingSheet, height: 300) {
                    SortingOptionsList(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
                }
            }
        }
        .ignoresSafeArea(.all)
        .animation(.interactiveSpring(), value: isShowingSheet)
    }
}

// MARK: - <즁요> DrinkInfoView 조립 예시 코드
// CustomSortingButton시 sheet뷰가 띄워질 때 ZStack으로 쌓여야한다.
struct DrawViewExampleCode: View {
    private let optionNameList = ["인기순", "도수 높은 순", "도수 낮은 순", "가격 높은 순", "가격 낮은 순"]
    
    @State private var isShowingSheet: Bool = false
    @State private var selectedSortingOption: String = "인기순"
    
    var body: some View {
        ZStack {
            VStack {
                DrinkSelectHorizontalScrollBar()
                DrinkInfoSegment(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
                Spacer()
                // TODO: DrinkInfoView 구성하는 구조체 넣기
            }
            // DrinkInfoSegment 클릭 시 띄워지는 CustomSheet뷰
            EnabledBottomSheetView(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
        }
    }
}

#Preview {
    DrawViewExampleCode()
}

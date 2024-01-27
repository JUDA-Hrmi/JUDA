//
//  DrinkInfoSegment.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/26.
//

import SwiftUI

// MARK: - 두 구조체 합친 버전 (뷰 그릴 때 이 구조체 사용)
struct DrinkInfoSegment: View {
    var body: some View {
        HStack {
            CustomChangeStyleSegment()
            Spacer()
            CustomSortingButton()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

//MARK: - 리스트/그리드 정렬 버튼
struct CustomChangeStyleSegment: View {
    private let cellStyleSymbolList = ["grid.style", "list.style"]
//    @Binding var selectedSymbolIndex: Int
    @State private var selectedSymbolIndex = 0 // 현재 뷰에서 어떤 이미지 tap 체크 변수
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<cellStyleSymbolList.count, id: \.self) { index in
                    Image(cellStyleSymbolList[index])
                        .foregroundStyle(index == selectedSymbolIndex ? .mainBlack : .gray01)
                        .onTapGesture {
                            withAnimation {
                                selectedSymbolIndex = index
                            }
                        }
                }
            }
        }
    }
}


//MARK: - 정렬 옵션 Sheet 버튼
struct CustomSortingButton: View {
    // Sheet 올라올 때 내부에 표시될 이름
    private let optionList = ["인기순", "도수 높은 순", "도수 낮은 순", "가격 높은 순", "가격 낮은 순"]
    
    @State private var isShowingSheet: Bool = false
    @State private var selectedSortingOption: String = "인기순"
    
    var body: some View {
        ZStack {
            Button(action: {
                isShowingSheet.toggle()
            }) {
                HStack(spacing: 5) {
                    Text(selectedSortingOption)
                        .font(.medium16)
                        .foregroundStyle(.mainBlack)
                    Image("arrow.style")
                        .foregroundStyle(.mainBlack)
                }
            }
            ZStack {
                Color.black.opacity(0.1)
                    .opacity(isShowingSheet ? 1 : 0)
                    .onTapGesture {
                        isShowingSheet.toggle()
                    }
                // '인기순' 클릭 -> CustomBottomSheet 올라옴
                if isShowingSheet {
                    CustomBottomSheet($isShowingSheet, height: 300) {
                        SortingOptionsView(optionList: optionList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
                    }
                }
            }
            .ignoresSafeArea(.all)
            .animation(.interactiveSpring(), value: isShowingSheet)
        }
    }
}


//#Preview {
//    SegmentBarVer2(selectedSymbolIndex: .constant(1))
//    BottomSheet(.constant(true), height: 300) {
//        SortingOptionCellListView(selectedSortingOption: .constant("인기순"))
//    }
//    .background(Color.secondary)
//
//}

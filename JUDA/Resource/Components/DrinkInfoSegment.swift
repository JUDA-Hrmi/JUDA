//
//  DrinkInfoSegment.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/26.
//

import SwiftUI

// MARK: - CustomChangeStyleSegment + CustomSortingButton
struct DrinkInfoSegment: View {
    let optionNameList: [String] // 정렬옵션 이름이 담겨진 리스트
    
    let selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    @Binding var isGridView: Bool
    
    var body: some View {
        HStack {
            CustomChangeStyleSegment(isGridView: $isGridView)
            Spacer()
            CustomSortingButton(optionNameList: optionNameList, selectedSortingOption: selectedSortingOption, isShowingSheet: $isShowingSheet)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - 리스트 / 그리드 아이콘 세그먼트
struct CustomChangeStyleSegment: View {
    private let cellStyleSymbolList = ["grid.style", "list.style"]
    @State private var selectedSymbolIndex = 0 // 현재 뷰에서 어떤 이미지 tap 체크 변수
    @Binding var isGridView: Bool
    
    var body: some View {
        HStack {
            HStack(spacing: 16) {
                ForEach(0..<cellStyleSymbolList.count, id: \.self) { index in
                    Image(cellStyleSymbolList[index])
                        .font(.medium18)
                        .foregroundStyle(index == selectedSymbolIndex ? .mainBlack : .gray01)
                        .onTapGesture {
                            selectedSymbolIndex = index
                            isGridView = selectedSymbolIndex == 0
                        }
                }
            }
        }
    }
}

// MARK: - 정렬 옵션 버튼
struct CustomSortingButton: View {
    let optionNameList: [String] // 정렬옵션 이름이 담겨진 리스트
    let selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        HStack {
            Button {
                isShowingSheet.toggle()
            } label: {
                HStack(spacing: 5) {
                    Text(selectedSortingOption)
                        .font(.medium16)
                        .foregroundStyle(.mainBlack)
                    Image(systemName: "chevron.down")
                        .foregroundStyle(.mainBlack)
                }
            }
        }
    }
}

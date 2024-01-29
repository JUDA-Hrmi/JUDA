//
//  DrinkInfoSegment.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/26.
//

import SwiftUI

// MARK: - CustomChangeStyleSegment + CustomSortingButton
struct DrinkInfoSegment: View {
    let optionNameList: [String] // 정렬옵션 이름이 담겨진 리스트
    
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    @Binding var isShowSymbolImage: Bool
    
    var body: some View {
        HStack {
            CustomChangeStyleSegment()
            Spacer()
            CustomSortingButton(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet, isShowSymbolImage: $isShowSymbolImage)
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

//MARK: - 정렬 옵션 버튼
struct CustomSortingButton: View {
    let optionNameList: [String] // 정렬옵션 이름이 담겨진 리스트
    
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    @Binding var isShowSymbolImage: Bool // <정렬옵션 글씨 + 심볼 이미지> OR <정렬옵션>
    
    var body: some View {
        HStack {
            Button(action: {
                isShowingSheet.toggle()
            }) {
                HStack(spacing: 5) {
                    Text(selectedSortingOption)
                        .font(.medium16)
                        .foregroundStyle(.mainBlack)
                    if isShowSymbolImage {
                        Image("arrow.style")
                            .foregroundStyle(.mainBlack)
                    }
                }
            }
        }
    }
}


#Preview {
    DrawViewExampleCode()
}

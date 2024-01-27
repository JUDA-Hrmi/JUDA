//
//  DrinkInfoSegment.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/26.
//

import SwiftUI

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

// MARK: - CustomChangeStyleSegment + CustomSortingButton
struct DrinkInfoSegment: View {
    let optionNameList: [String] // 정렬옵션 이름이 담겨진 리스트
    
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        HStack {
            CustomChangeStyleSegment()
            Spacer()
            CustomSortingButton(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
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
    
    var body: some View {
        HStack {
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
        }
    }
}


#Preview {
    DrawViewExampleCode()
}

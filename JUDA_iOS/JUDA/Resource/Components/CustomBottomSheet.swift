//
//  CustomBottomSheet.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/27.
//

import SwiftUI

// MARK: - 바텀 시트 타입
enum BottomSheetType {
    static let drinkInfo = "정렬 옵션 설정" // DrinkInfoView에서 쓰는 bottomSheet
    static let displaySetting = "화면 모드 설정" // 'SettingView - 화면 모드 설정' 에서 쓰는 bottomSheet
}

// MARK: - .sheet 의 content 부분.
struct CustomBottomSheetContent: View{
    let optionNameList: [String]
    @Binding var isShowingSheet: Bool
    @Binding var selectedSortingOption: String
    let bottomSheetTypeText: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            // 정렬 타이틀
            Text(bottomSheetTypeText)
                .foregroundColor(.mainBlack)
                .font(.light14)
            
            // 선택 리스트
            VStack(spacing: 30) {
                ForEach(optionNameList, id: \.self) { option in
                    BottomSheetContentListCell(sortingOptionName: option,
                                               selectedSortingOption: $selectedSortingOption,
                                               isShowingSheet: $isShowingSheet)
                }
            }
            //
            CustomDivider()
            // '닫기' 버튼
            Button {
                isShowingSheet.toggle()
            } label: {
                Text("닫기")
                    .font(.medium18)
                    .foregroundStyle(.mainBlack)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
    }
}

// MARK: - CustomBottomSheetContent 구성 Cell
struct BottomSheetContentListCell: View {
    let sortingOptionName: String // 정렬 옵션 항목 이름
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        Button {
            // 해당 cell 클릭 시 CustomSortingButton에 표시되는 문구 변경
            selectedSortingOption = sortingOptionName
            isShowingSheet.toggle()
        } label: {
            // 선택된 항목일 때 색상 및 글씨체 변화주기
            if selectedSortingOption == sortingOptionName {
                HStack {
                    Text(sortingOptionName)
                        .font(.bold18)
                    Spacer()
                    Image(systemName: "checkmark")
                }
                .foregroundStyle(.mainAccent03)
            } else {
                HStack {
                    Text(sortingOptionName)
                        .font(.medium18)
                    Spacer()
                }
                .foregroundStyle(.mainBlack)
            }
        }
        .padding(.horizontal, 20)
    }
}

//
//  test.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/02/01.
//

// MARK: CustomBottomContents -> CustomBottomSheet에 들어갈 contents View 모음집 입니다.

import SwiftUI

enum BottomSheetType: String {
    case drinkInfo // DrinkInfoView에서 쓰는 bottomSheet
    case displaySetting // 'SettingView - 화면 모드 설정' 에서 쓰는 bottomSheet
    
    var description: String {
        switch self {
        case .drinkInfo:
            "정렬 옵션 모드"
        case .displaySetting:
            "화면 모드 설정"
        }
    }
}

// BottomSheet 위에 띄워질 뷰
// BottomSheet의 content 부분.
// 여기서 원하는 내용으로 만들어서 쓰면 된다.
struct BottomSheetContentView: View{
    let buttonHeight: CGFloat = 55
    let optionNameList: [String]
    
    @Binding var isShowingSheet: Bool
    @Binding var selectedSortingOption: String
    var text: String
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Text(text)
                    .foregroundColor(.mainBlack)
                    .font(.light14)
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            BottomSheetContentsList(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
            
            CustomDivider()
                .padding(.bottom, 10)
            
            DismissButton {
                isShowingSheet.toggle()
            }
            .frame(height: buttonHeight - 30)
        }
    }
}

// 적용 예시
struct Content2View: View {
    private let optionNameList = ["시스템 모드", "라이트 모드", "다크 모드"]
 
    @State private var selectedSortingOption: String = "시스템 모드"
    @State var isShowingBottomSheet = false
    
    var body: some View {
        ZStack{
            CustomSortingButton(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingBottomSheet)
            
            // BottomSheetType을 활용하여 Content 뷰 부르기
            CustomBottomSheet(isShowingSheet: $isShowingBottomSheet) {
                BottomSheetContentView(optionNameList: optionNameList, isShowingSheet: $isShowingBottomSheet, selectedSortingOption: $selectedSortingOption, text: BottomSheetType.displaySetting.description)
            }
        }
    }
}

#Preview {
    Content2View()
}

//
//  test.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/02/01.
//

// MARK: CustomBottomContents -> CustomBottomSheet에 들어갈 contents View 모음집 입니다.

import SwiftUI

enum BottomSheetType {
    case drinkInfo // DrinkInfoView에서 쓰는 bottomSheet
    case displaySetting // 'SettingView - 화면 모드 설정' 에서 쓰는 bottomSheet
    
    func view(optionNameList: [String] ,isShowingSheet: Binding<Bool>, selectedSortingOption: Binding<String>) -> AnyView {
        switch self {
        case .drinkInfo:
            return AnyView(DrinkInfoSortingBottomSheet(optionNameList: optionNameList, isShowingSheet: isShowingSheet, selectedSortingOption: selectedSortingOption))
        case .displaySetting:
            return AnyView(DisplaySettingBottomSheet(optionNameList: optionNameList, isShowingSheet: isShowingSheet, selectedSortingOption: selectedSortingOption))
        }
    }
}

// BottomSheet 위에 띄워질 뷰
// BottomSheet의 content 부분.
// 여기서 원하는 내용으로 만들어서 쓰면 된다.
struct DrinkInfoSortingBottomSheet: View{
    let buttonHeight: CGFloat = 55
    let optionNameList: [String]
    
    @Binding var isShowingSheet: Bool
    @Binding var selectedSortingOption: String
    
    var body: some View{
        VStack(alignment: .center) {
            HStack {
                Text("정렬 방식 선택")
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

// BottomSheet 위에 띄워질 뷰
struct DisplaySettingBottomSheet: View{
    let buttonHeight: CGFloat = 55
    let optionNameList: [String]
    
    @Binding var isShowingSheet: Bool
    @Binding var selectedSortingOption: String
    
    var body: some View{
        VStack(alignment: .center) {
            HStack {
                Text("화면 모드 선택")
                    .foregroundColor(.mainBlack)
                    .font(.light14)
                
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            BottomSheetContentsList(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
            
            CustomDivider()
                .padding(.bottom, 10)
            
            DismissButton(action: {
                isShowingSheet.toggle()
            })
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
            CustomBottomSheet(isShowingSheet: $isShowingBottomSheet, content: BottomSheetType.drinkInfo.view(optionNameList: optionNameList, isShowingSheet: $isShowingBottomSheet, selectedSortingOption: $selectedSortingOption))
        }
    }
}

#Preview {
    Content2View()
}

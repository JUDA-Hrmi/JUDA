//
//  test.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/02/01.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorners(radius: radius, corners: corners) )
    }
}

struct RoundedCorners: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

enum BottomSheetType: Int {
    case drinkInfo
    case displaySetting
    
    func view(optionNameList: [String] ,isShowing: Binding<Bool>, selectedSortingOption: Binding<String>) -> AnyView {
        switch self {
        case .drinkInfo:
            return AnyView(DrinkInfoSortingBottomSheet(optionNameList: optionNameList, isShowing: isShowing, selectedSortingOption: selectedSortingOption))
        case .displaySetting:
            return AnyView(DisplaySettingBottomSheet(optionNameList: optionNameList, isShowing: isShowing, selectedSortingOption: selectedSortingOption))
        }
    }
}

struct BottomSheet: View {
    @Binding var isShowing: Bool
    var content: AnyView
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if (isShowing) {
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }
                content
                    .padding(.bottom, 42)
                    .transition(.move(edge: .bottom))
                    .background(
                        Color(uiColor: .white)
                    )
                    .cornerRadius(16, corners: [.topLeft, .topRight])
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.interactiveSpring, value: isShowing)
    }
}

struct DismissButton: View {
    var background: Color = .white
    var textColor: Color = .black.opacity(0.9)
    var action: (() -> ())
    let cornorRadius: CGFloat = 8
    
    var body: some View {
        VStack {
            Button(action: {
                action()
            }, label: {
                Text("닫기")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
        }
    }
}

// BottomSheet 안의 내용
struct DrinkInfoSortingBottomSheet: View{
    let buttonHeight: CGFloat = 55
    let optionNameList: [String]
    
    @Binding var isShowing: Bool
    @Binding var selectedSortingOption: String
    
    var body: some View{
        VStack(alignment: .leading) {
            HStack {
                Text("정렬 방식 선택")
                    .foregroundColor(.black.opacity(0.9))
                    .font(.light14)

                Spacer()
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            
            SortingOptionsList(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowing)
            DismissButton {
                isShowing.toggle()
            }
            .frame(height: buttonHeight)
        }
        .padding(.horizontal, 16)
    }
}

struct DisplaySettingBottomSheet: View{
    let buttonHeight: CGFloat = 55
    let optionNameList: [String]
    
    @Binding var isShowing: Bool
    @Binding var selectedSortingOption: String
    
    var body: some View{
        VStack(alignment: .center) {
            HStack {
                Text("화면 모드 선택")
                    .foregroundColor(.black.opacity(0.9))
                    .font(.light14)
                
            }
            .padding(.top, 16)
            .padding(.bottom, 4)
            SortingOptionsList(optionNameList: optionNameList, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowing)
            CustomDivider()
            DismissButton(action: {
                isShowing.toggle()
            })
            .frame(height: buttonHeight - 10)
        }
        .padding(.horizontal, 16)
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
            
            BottomSheet(isShowing: $isShowingBottomSheet, content: BottomSheetType.displaySetting.view(optionNameList: optionNameList, isShowing: $isShowingBottomSheet, selectedSortingOption: $selectedSortingOption))
        }
    }
}

#Preview {
    Content2View()
}

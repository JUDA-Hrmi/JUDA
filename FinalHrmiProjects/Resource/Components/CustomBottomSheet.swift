//
//  CustomBottomSheet.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/27.
//

import SwiftUI

// MARK: CustomBottomSheet
struct CustomBottomSheet: View {
    @Binding var isShowingSheet: Bool // CustomBottomSheet 호출 시, 함수 동작을 더 잘 나타내기 위해 상태변수 먼저 작성
    
    var content: AnyView
    @Environment(\.colorScheme) var scheme
    var body: some View {
        ZStack(alignment: .bottom) {
            if (isShowingSheet) { // Sheet활성화 됐을 때 뒷배경
                Color.gray01
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowingSheet.toggle()
                    }
                content // Sheet에 올라갈 Content 내용
                    .padding(.bottom, 42)
                    .transition(.move(edge: .bottom))
                    .background(
                        Theme.backgroundColor(scheme: scheme)
                    )
                    .clipShape(
                        .rect(topLeadingRadius: 16.0, topTrailingRadius: 16.0)
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .ignoresSafeArea()
        .animation(.interactiveSpring, value: isShowingSheet)
    }
}

// content에 같이 들어갈 '닫기' 버튼
struct DismissButton: View {
    var background: Color = .white
    var textColor: Color = .mainBlack
    var action: (() -> ())
    let cornorRadius: CGFloat = 8
    
    var body: some View {
        VStack {
            Button(action: {
                action()
            }, label: {
                Text("닫기")
                    .font(.medium18)
                    .foregroundStyle(.mainBlack)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            })
        }
    }
}


// MARK: -  CustomBottomSheet 안에 띄워질 Content뷰
struct BottomSheetContentsList: View {
    let optionNameList: [String] // 정렬옵션 이름이 담겨진 리스트
    
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool

    var body: some View {
        VStack {
            // CustomBottomSheet 안에 보여줄 항목 리스트 형태로 그리기.
            ForEach(optionNameList, id: \.self) { option in
                BottomSheetContentCell(sortingOptionName: option, selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet)
            }
        }
    }
}

// MARK: -  BottomSheetContentsList 구성 Cell
struct BottomSheetContentCell: View {
    let sortingOptionName: String // 정렬 옵션 항목 이름
    
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding var isShowingSheet: Bool
    
    var body: some View {
        Button(action: {
            // 해당 cell 클릭 시 CustomSortingButton에 표시되는 문구 변경
            selectedSortingOption = sortingOptionName
            isShowingSheet.toggle()
        }, label: {
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
                    Text("")

                }
                .foregroundStyle(.mainBlack)
            }
        })
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
    }
}

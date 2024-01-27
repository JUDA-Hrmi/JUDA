//
//  CustomBottomSheet.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/27.
//

import SwiftUI

struct CustomBottomSheet<Content>: View where Content: View {
    public var height: CGFloat
    public var content: Content
    
    @Binding private var isShowingSheet: Bool
    @GestureState private var translation: CGFloat = .zero - 50
    
    public init(_ isShowingSheet: Binding<Bool>, height: CGFloat, content: () -> Content) {
        self._isShowingSheet = isShowingSheet
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(height: 50)
                .overlay(
                    Text("정렬 방식 선택")
                        .font(.light14)
                )
            self.content
                .frame(height: self.height)
        }
        .frame(height: self.height + 10)
        .background(
            Rectangle()
                .fill(.white)
                .ignoresSafeArea(.all, edges: [.bottom, .horizontal])
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .offset(y: translation + height) // 화면의 하단으로부터 얼마나 떨어질지.
        .gesture(
            DragGesture()
                .updating($translation, body: { value, state, _ in
                    if 0 <= value.translation.height {
                        let translation = min(self.height, max(-self.height, value.translation.height))
                        state = translation
                    }
                })
                .onEnded({ value in
                    if value.translation.height >= height/3 {
                        self.isShowingSheet.toggle()
                    }
                })
        )
    }
}

// MARK: -  CustomBottomSheet 안에 띄울 뷰
struct SortingOptionsView: View {
    let optionList: [String]
    
    @Binding var selectedSortingOption: String
    @Binding var isShowingSheet: Bool

    var body: some View {
        VStack {
            // CustomBottomSheet 안에 보여줄 항목 리스트 형태로 그리기.
            ForEach(optionList, id: \.self) { option in
                SortingOptionCell(selectedSortingOption: $selectedSortingOption, isShowingSheet: $isShowingSheet, sortingOptionName: option)
            }
            Divider()
            Button(action: {
                isShowingSheet.toggle()
            }, label: {
                Text("닫기")
                    .font(.bold20)
                    .foregroundStyle(.mainBlack)
            })
            .padding(.bottom, 50)
        }
    }
}

// MARK: -  SortingOptionsView 구성 Cell
struct SortingOptionCell: View {
    @Binding var selectedSortingOption: String // 선택된 항목 이름
    @Binding public var isShowingSheet: Bool
    
    let sortingOptionName: String // 정렬 옵션 항목 이름
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
        .padding(.vertical, 10)
    }
}


//#Preview {
//    CustomBottomSheet(.constant(true), height: 300) {
//        SortingOptionCellListView(selectedSortingOption: .constant("인기순"))
//    }
//}

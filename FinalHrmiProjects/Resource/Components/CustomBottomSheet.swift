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
    
    @Binding public var isShowingSheet: Bool
    @GestureState private var translation: CGFloat = .zero
    
    public init(_ isShowingSheet: Binding<Bool>, height: CGFloat, content: () -> Content) {
        self._isShowingSheet = isShowingSheet
        self.height = height
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: .zero) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .frame(height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 100)
                        .foregroundStyle(.gray01)
                        .frame(width: 60, height: 5)
                )
            self.content
                .frame(height: self.height)
        }
        .frame(height: self.height + 10)
        .background(
            Rectangle()
                .fill(.white)
                .edgesIgnoringSafeArea([.bottom, .horizontal])
        )
        .transition(.opacity.combined(with: .move(edge: .bottom)))
        .offset(y: translation + height) // Adjust offset to place at the bottom
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

struct SortingOptionCell: View {
    @Binding var selectedSortingOption: String
    @Binding public var isShowingSheet: Bool
    
    let sortingOptionName: String
    var body: some View {
        Button(action: {
            // 해당 cell 클릭 시 CustomSortingButton에 표시되는 문구 변경
            selectedSortingOption = sortingOptionName
            isShowingSheet.toggle()
        }, label: {
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

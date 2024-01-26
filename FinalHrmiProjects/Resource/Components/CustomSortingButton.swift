//
//  CustomSortingButton.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/25.
//

import SwiftUI

//MARK: 인기/최신순 정렬
struct CustomSortingButton: View {
    @State private var isShowingSheet: Bool = false
    @State private var selectedSortingOption: String = "인기순"
    
    var body: some View {
        VStack {
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
            .actionSheet(isPresented: $isShowingSheet) {
                ActionSheet(
                    //TODO: 정렬 옵션 논의 후 추가하기
                    title: Text("정렬 방식 선택"),
                    buttons: [
                        .default(Text("인기순")) {
                            selectedSortingOption = "인기순"
                            // TODO: 정렬 결과를 표시하는 함수 호출
                        },
                        .default(Text("최신순")) {
                            selectedSortingOption = "최신순"
                            // TODO: 정렬 결과를 표시하는 함수 호출
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}

#Preview {
    CustomSortingButton()
}

//
//  CustomSortingButton.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/25.
//

import SwiftUI

struct CustomSortingButton: View {
    @State private var isShowingSheet = false
    @State private var selectedSortingOption = "인기순"
    
    var body: some View {
        VStack {
            Button(action: {
                isShowingSheet.toggle()
            }) {
                Text(selectedSortingOption)
                    .font(.medium16)
                    .foregroundStyle(.mainBlack)
            }
            .actionSheet(isPresented: $isShowingSheet) {
                ActionSheet(
                    title: Text("정렬 방식 선택"),
                    buttons: [
                        .default(Text("인기순")) {
                            selectedSortingOption = "인기순"
                            // 정렬 결과를 표시하는 함수 호출
                        },
                        .default(Text("최신순")) {
                            selectedSortingOption = "최신순"
                            // 정렬 결과를 표시하는 함수 호출
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

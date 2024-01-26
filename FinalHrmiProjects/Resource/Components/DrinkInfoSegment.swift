//
//  DrinkInfoSegment.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/26.
//

import SwiftUI

// MARK: 두 구조체 합친 버전 (뷰 그릴 때 이 구조체 사용)
struct DrinkInfoSegment: View {
    var body: some View {
        HStack {
            CustomChangeStyleSegment()
            Spacer()
            CustomSortingButton()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

//MARK: 리스트/그리드 정렬 버튼
struct CustomChangeStyleSegment: View {
    private let cellStyle = ["grid.style", "list.style"]
//    @Binding var selectedSymbolIndex: Int
    @State private var selectedSymbolIndex = 0 // 현재 뷰에서 어떤 이미지 tap 체크 변수
    var body: some View {
        HStack {
            HStack(spacing: 5) {
                ForEach(0..<cellStyle.count, id: \.self) { index in
                    Image(cellStyle[index])
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
//    SegmentBarVer2(selectedSymbolIndex: .constant(1))
    DrinkInfoSegment()
}

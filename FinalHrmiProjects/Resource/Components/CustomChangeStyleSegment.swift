//
//  SegmentBarVer2.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/25.
//

import SwiftUI

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

// MARK: 두 구조체 합친 버전 (뷰 그릴 때 이 구조체 사용)
struct DrinkInfoSegment: View {
    var body: some View {
        HStack {
            CustomChangeStyleSegment()
            Spacer()
            CustomSortingButton()
        }
        // 양쪽 padding 20씩 설정
        .padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
    }
}

#Preview {
//    SegmentBarVer2(selectedSymbolIndex: .constant(1))
    DrinkInfoSegment()
}

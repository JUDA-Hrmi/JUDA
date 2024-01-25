//
//  SegmentBarVer2.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/25.
//

import SwiftUI

struct CustomChangeStyleSegment: View {
    private let cellStyle = ["grid.style", "list.style"]
//    @Binding var selectedSymbolIndex: Int
    
    // 현재 뷰에서 tap 체크용
    @State private var selectedSymbolIndex = 0
    var body: some View {
        HStack {
            HStack {
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

#Preview {
//    SegmentBarVer2(selectedSymbolIndex: .constant(1))
    CustomChangeStyleSegment()
}

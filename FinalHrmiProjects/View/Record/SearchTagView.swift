//
//  SearchTagView.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// Defualt로 찜 목록 보여주기
struct SearchTagView: View {
    // TODO: 데이터 타입 변경 필요
    // Sheet 상태 변수
    @Binding var isShowTagSearch: Bool
    // 찜 목록 가져오는 배열
    private let likeds: [String] = []

    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
                SearchBar()
                // Sheet 내려주기
                // TODO: XmarkOnGrayCircle로 변경
                Button {
                    isShowTagSearch.toggle()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray01, .gray06)
                        .font(.title)
                        .padding(.trailing, 15)
                }
            }
            .padding(.top, 20)
            
            // 찜 목록이 없을 때, 임의의 텍스트 보여주기
            if likeds.isEmpty {
                Spacer()
                Text("술찜 없을 때 텍스트")
                    .font(.regular14)
                    .foregroundStyle(.gray01)
                Spacer()
            } else {
                // 찜 목록이 있을 때, DrinkListCell 리스트로 보여주기
                ScrollView {
                    ForEach(likeds, id: \.self) { liked in
                        DrinkListCell()
                    }
                }
            }

        }
    }
}

#Preview {
    SearchTagView(isShowTagSearch: .constant(true))
}

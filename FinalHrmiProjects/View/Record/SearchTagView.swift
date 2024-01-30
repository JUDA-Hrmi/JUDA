//
//  SearchTagView.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

struct SearchTagView: View {
    // Sheet 상태 변수
    @Binding var isShowTagSearch: Bool

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
        }
    }
}

#Preview {
    SearchTagView(isShowTagSearch: .constant(true))
}

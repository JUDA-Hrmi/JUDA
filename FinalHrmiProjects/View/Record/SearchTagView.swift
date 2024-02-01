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
    private let likeds: [String] = ["1","2","3","4","5","6","7","8"]

	@State private var tagSearchText = ""
	
    var body: some View {
        VStack {
            HStack(alignment: .center, spacing: 0) {
				SearchBar(inputText: $tagSearchText)
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
                // TODO: 텍스트 내용 변경
                Text("술찜 없을 때 텍스트")
                    .font(.regular14)
                    .foregroundStyle(.gray01)
                Spacer()
            } else {
                // 찜 목록이 있을 때, DrinkListCell 리스트로 보여주기
                ScrollView {
                    ForEach(likeds, id: \.self) { _ in
                        // TODO: Cell 클릭 시 별점 평가 Dialog 띄우기
                        DrinkListCell()
                    }
                }
                // 스크롤 했을 때, 키보드 사라지기
                .scrollDismissesKeyboard(.immediately)
            }

        }
        // 화면 탭했을 때, 키보드 사라지기
        .onTapGesture {
            hideKeyboard()
        }
    }
}

#Preview {
    SearchTagView(isShowTagSearch: .constant(true))
}

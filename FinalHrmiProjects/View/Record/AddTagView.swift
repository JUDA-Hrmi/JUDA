//
//  AddTagView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct AddTagView: View {
    // TODO: 데이터 타입 변경 필요
    // 이미지 배열
    @State private var selectedPhotos: [UIImage?] = Array(repeating: nil, count: 10)
    // SearchTagView sheet 프로퍼티
    @State private var isShowTagSearch = false

    var body: some View {
        VStack {
            // 사진 선택 및 선택된 사진을 보여주는 수평 스크롤 이미지 뷰
            // TODO: sheet로 올라오는 photopicker에 선택된 사진 체크 처리 및 이미지 뷰 수정
            ImageSelectHorizontalScrollView(selectedPhotos: $selectedPhotos)
                .padding(.horizontal, 20)
            
            // 술 태그 추가 버튼
            Button {
                // 클릭 시 SearchTagView Sheet 띄워주기
                isShowTagSearch.toggle()
            } label: {
                Text("술 태그 추가하기")
                    .font(.medium20)
                    .foregroundStyle(.mainAccent03)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(style: StrokeStyle())
                            .tint(.mainAccent03)
                    }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)


        }
    }
}

#Preview {
    AddTagView()
}

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

    var body: some View {
        VStack {
            // 사진 선택 및 선택된 사진을 보여주는 수평 스크롤 이미지 뷰
            // TODO: sheet로 올라오는 photopicker에 선택된 사진 체크 처리 및 이미지 뷰 수정
            ImageSelectHorizontalScrollView(selectedPhotos: $selectedPhotos)
                .padding(.horizontal, 20)

        }
    }
}

#Preview {
    AddTagView()
}

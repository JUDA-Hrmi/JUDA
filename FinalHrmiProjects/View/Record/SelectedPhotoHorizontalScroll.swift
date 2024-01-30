//
//  SelectedPhotoHorizontalScroll.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// 선택된 사진들을 보여주는 스크롤뷰
struct SelectedPhotoHorizontalScroll: View {
    @Binding var images: [String]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(0..<images.count, id: \.self) { index in
                    ZStack(alignment: .topTrailing) {
                        Image(images[index])
                            .resizable()
                            // TODO: frame 가변으로 변경
                            .frame(width: 100, height: 100)
                            .clipShape(.rect(cornerRadius: 10))
                        Button {
                            // 사진 배열에서 해당 사진 삭제
                            images.remove(at: index)
                        } label: {
                            // TODO: XmarkOnGrayCircle 변경
                            Image(systemName: "xmark.circle.fill")
                                // 심볼 레이어별로 색상 지정할 수 있게 렌더링모드 .palette 설정
                                // xmark 색상 gray06, circle 색상 gray01
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(.gray06, .gray01.opacity(0.6))
                                .font(.title3)
                                .padding(3)
                        }
                    }
                }
            }
        }
        // TODO: frame 가변으로 변경
        .frame(height: 100)
        .padding(.leading, 20)

    }
}

//#Preview {
//    SelectedPhotoHorizontalScroll()
//}

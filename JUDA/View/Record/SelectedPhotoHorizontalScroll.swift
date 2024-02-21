//
//  SelectedPhotoHorizontalScroll.swift
//  JUDA
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI

// MARK: - 선택된 사진들을 보여주는 스크롤뷰
struct SelectedPhotoHorizontalScroll: View {
    @EnvironmentObject private var recordVM: RecordViewModel
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(0..<recordVM.images.count, id: \.self) { index in
                    Image(uiImage: recordVM.images[index])
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
        .frame(height: 120)
        .padding(.leading, 20)
        .padding(.vertical, 10)
    }
}

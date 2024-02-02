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
    let recordType: RecordType
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                ForEach(0..<images.count, id: \.self) { index in
                    if recordType == .edit {
                        NavigationLink(destination: {
                            AddTagView()
                        }, label: {
                            Image(images[index])
                                .resizable()
                            // TODO: frame 가변으로 변경
                                .frame(width: 100, height: 100)
                                .clipShape(.rect(cornerRadius: 10))
                        })
                        .buttonStyle(EmptyActionStyle())
                    } else {
                        Image(images[index])
                            .resizable()
                        // TODO: frame 가변으로 변경
                            .frame(width: 100, height: 100)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                    
                }
            }
        }
        // TODO: frame 가변으로 변경
        .frame(height: 100)
        .padding(.leading, 20)
        .padding(.vertical, 10)
        .scrollIndicators(.hidden)
    }
}

//#Preview {
//    SelectedPhotoHorizontalScroll()
//}

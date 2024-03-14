//
//  SelectedPhotoHorizontalScroll.swift
//  JUDA
//
//  Created by 정인선 on 1/30/24.
//

import SwiftUI
import Kingfisher

// MARK: - 선택된 사진들을 보여주는 스크롤뷰
struct SelectedPhotoHorizontalScroll: View {
    @EnvironmentObject private var recordViewModel: RecordViewModel
    // post add/edit
    let recordType: RecordType
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHStack(spacing: 10) {
                switch recordType {
                // post add
                case .add:
                    // 라이브러리에서 선택된 사진 image로 보여주기
                    ForEach(0..<recordViewModel.selectedImages.count, id: \.self) { index in
                        Image(uiImage: recordViewModel.selectedImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 100, height: 100)
                            .clipShape(.rect(cornerRadius: 10))
                    }
                // post edit
                case .edit:
                    if let post = recordViewModel.post {
                        // post가 가진 ImagesURL을 KFImage로 보여주기
                        ForEach(0..<(post.postField.imagesURL.count), id: \.self) { index in
                            SelectedImageKFImage(url: post.postField.imagesURL[index])
                        }
                    }
                }
            }
        }
        .frame(height: 120)
        .padding(.leading, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - 술 리스트 셀 사용 KingFisher 이미지
private struct SelectedImageKFImage: View {
    // post가 가진 imageURL
    let url: URL
    
    var body: some View {
        KFImage.url(url)
            .placeholder {
                CircularLoaderView(size: 20)
                    .frame(width: 100, height: 100)
            }
            .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
            .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
            .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
            .fade(duration: 0.2) // 이미지 부드럽게 띄우기
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipShape(.rect(cornerRadius: 10))
    }
}

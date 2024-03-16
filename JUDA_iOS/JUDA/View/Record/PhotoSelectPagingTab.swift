//
//  PhotoSelectPagingTab.swift
//  JUDA
//
//  Created by 정인선 on 1/29/24.
//

import SwiftUI
import PhotosUI

// MARK: - 글 작성 시, 선택된 사진들 페이징 뷰
struct PhotoSelectPagingTab: View {
    @EnvironmentObject private var recordViewModel: RecordViewModel
    // 현재 선택된 탭의 인덱스. 초기값 0
    @State private var selectedIndex = 0
    // photo picker로 선택된 사진 배열
    @Binding var selectedPhotos: [PhotosPickerItem]
    // 이미지 가져오다가 에러나면 띄워줄 alert
    @Binding var isShowAlert: Bool
    // 이미지 사이즈
    let imageSize: CGFloat
    // 최대로 고를 수 있는 이미지 개수
    private let maxImages = 10
    
    var body: some View {
        VStack(alignment: .leading) {
            // 사진 등록 텍스트
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("사진 등록")
                    .font(.regular16)
                Text("* 필수 (최대 10장)")
                    .font(.regular14)
                    .foregroundStyle(.gray01)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            // 선택된 사진들을 탭뷰 페이징 형식으로 보여주기
            TabView(selection: $selectedIndex) {
                Group {
                    ForEach(recordViewModel.selectedImages.indices, id: \.self) { index in
                        // 이미지
                        Image(uiImage: recordViewModel.selectedImages[index])
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: imageSize, height: imageSize)
                            .clipped()
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    removePhoto(index)
                                } label: {
                                    XmarkOnGrayCircle()
                                        .font(.title2)
                                        .padding([.top, .trailing], 10)
                                }
                            }
                            .tag(index + 1)
                    }
                    // 선택된 사진이 10장보다 적을 때,
                    if recordViewModel.selectedImages.count < maxImages {
                        // 사진 선택 (포토픽커)
                        LibraryPhotosPicker(selectedPhotos: $selectedPhotos, maxSelectionCount: maxImages) {
                            Image(systemName: "plus.circle.fill")
                                .font(.largeTitle)
                                .frame(width: imageSize, height: imageSize)
                                .background(.gray06)
                        }.tag(recordViewModel.selectedImages.count + 1)
                    }
                }
            }
            .frame(height: imageSize)
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            // 앨범에서 사진 선택 시, 화면에 보여줄 배열에 이미지 변환 및 업데이트
            .onChange(of: selectedPhotos) { _ in
                Task {
                    do {
                        try await updateImage()
                    } catch {
                        // 이미지 로드 실패 alert 띄워주기
                        isShowAlert = true
                    }
                }
            }
            // 현재 보이는 사진 맨 뒤 사진으로 수정
            .onChange(of: recordViewModel.selectedImages) { _ in
                Task {
                    selectedIndex = recordViewModel.selectedImages.count
                }
            }
        }
        .tint(.mainBlack)
    }
    
    private func updateImage() async throws {
        // 선택된 사진 하나도 없으면, 배열 비우고 바로 리턴
        guard !selectedPhotos.isEmpty else {
            recordViewModel.selectedImages = []
            return
        }
        var images = [UIImage]() // 임시 배열 (작업 끝나면 배열채로 한번에 업데이트
        for selectedPhoto in selectedPhotos {
            do {
                // 데이터로 변환 -> 이미지로 변환
                guard let data = try await selectedPhoto.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else {
                    throw PhotosPickerImageLoadingError.invalidImageData
                }
                images.append(uiImage)
            } catch {
                throw PhotosPickerImageLoadingError.invalidImageData
            }
        }
        recordViewModel.selectedImages = images
        self.selectedIndex = recordViewModel.selectedImages.count
    }
    
    private func removePhoto(_ index: Int) {
        recordViewModel.selectedImages.remove(at: index)
        selectedPhotos.remove(at: index)
    }
}

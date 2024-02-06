//
//  PhotoSelectPagingTab.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/29/24.
//

import SwiftUI
import PhotosUI

// MARK: - Photos Data
struct PhotoData: Identifiable {
    let id = UUID()
    var image: UIImage?
}

struct PhotoSelectPagingTab: View {
    // 현재 선택된 탭의 인덱스. 초기값 0
    @State private var selectedIndex = 0
    // photo picker로 선택된 이미지 배열
    @Binding var images: [UIImage?]
    // photo picker로 선택된 사진 배열
    @Binding var selectedPhotos: [PhotosPickerItem]
    let imageSize: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline, spacing: 6) {
                Text("사진 등록")
                    .font(.regular16)
                Text("(최대 10장)")
                    .font(.regular14)
                    .foregroundStyle(.gray01)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 10)

            HStack {
                // 선택된 사진들을 탭뷰 페이징 형식으로 보여주기
                TabView(selection: $selectedIndex) {
                    Group {
                        ForEach($images.indices, id: \.self) { index in
                            ImageView(images: $images,
                                      selectedPhotos: $selectedPhotos,
                                      currentIndex: index,
                                      imageSize: imageSize)
                            .tag(index)
                        }
                        // images에 사진을 선택할 수 있는 잔여 공간이 남아있는 경우, + 버튼 활성화
                        if images.contains(nil) {
                            LibraryPhotosPicker(selectedPhotos: $selectedPhotos, maxSelectionCount: 10) { // 최대 10장
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .frame(width: imageSize, height: imageSize)
                                    .background(.gray06)
                                
                            }
                            .tag(selectedPhotos.endIndex + 1)
                        }
                    }
                    .task(id: selectedPhotos) {
                        await updateImages()
                    }
                    .onChange(of: images) { _ in
                        updateSelectedIndex()
                    }
                }
                .frame(height: imageSize)
                .tabViewStyle(.page(indexDisplayMode: .automatic))
            }
        }
		.tint(.mainBlack)
    }
    
    @MainActor
    private func updateImages() async {
        // 선택한 사진이 비어있으면 저장할 사진 목록 초기화하고 return
        guard !selectedPhotos.isEmpty else {
            images = Array(repeating: nil, count: 10)
            return
        }
        // 저장할 목록의 크기만큼 순회
        for index in 0..<images.count {
            // 선택할 사진들의 개수가 현재 index 보다 큰 경우,
            if selectedPhotos.count > index {
                do {
                    // 선택한 사진 index 접근
                    let selectedPhoto = selectedPhotos[index]
                    // 데이터로 transfer
                    guard let data = try await selectedPhoto.loadTransferable(type: Data.self) else {
                        print("Error photo to data")
                        return
                    }
                    // UIimage 로 변경
                    let image = UIImage(data: data)
                    images[index] = image
                } catch let error {
                    print("Error loading image: \(error.localizedDescription)")
                }
            // 선택할 사진들의 개수가 현재 index 보다 작거나 같은 경우, 배열 비워주기
            } else {
                images[index] = nil
            }
        }
    }
    
    @MainActor
    private func updateSelectedIndex() {
        selectedIndex = images.lastIndex(where: { $0 != nil }) ?? 0
    }
}

struct ImageView: View {
    // 이미지
    @Binding var images: [UIImage?]
    // 사진
    @Binding var selectedPhotos: [PhotosPickerItem]
    let currentIndex: Int
    let imageSize: CGFloat
    
    var body: some View {
        if let image = images[currentIndex] {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: imageSize, height: imageSize)
                .clipped()
                .overlay(alignment: .topTrailing) {
                    Button {
                        removePhoto()
                    } label: {
                        XmarkOnGrayCircle()
                            .font(.title2)
                            .padding([.top, .trailing], 10)
                    }
                }
        }
    }
    
    @MainActor
    private func removePhoto() {
        self.images.remove(at: currentIndex)
        self.selectedPhotos.remove(at: currentIndex)
        images.append(nil)
    }
}

//#Preview {
//    PhotoSelectPagingTab()
//}

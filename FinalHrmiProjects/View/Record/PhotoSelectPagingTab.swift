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

enum ImageLoadingError: Error {
    case invalidImageData
}

struct PhotoSelectPagingTab: View {
    // 현재 선택된 탭의 인덱스. 초기값 0
    @State private var selectedIndex = 0
    // photo picker로 선택된 이미지 배열
    @Binding var images: [UIImage]
    // photo picker로 선택된 사진 배열
    @Binding var selectedPhotos: [PhotosPickerItem]
    let imageSize: CGFloat
    
    private let maxImages = 10
    
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
                        ForEach(images.indices, id: \.self) { index in
                            Image(uiImage: images[index])
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
                        if images.count < maxImages {
                            LibraryPhotosPicker(selectedPhotos: $selectedPhotos,
                                                maxSelectionCount: maxImages) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.largeTitle)
                                    .frame(width: imageSize, height: imageSize)
                                    .background(.gray06)
                            }.tag(images.count + 1)
                        }
                    }
                }
                .frame(height: imageSize)
                .tabViewStyle(.page(indexDisplayMode: .automatic))
                .onChange(of: selectedPhotos) { _ in
                    Task {
                        await updateImage()
                    }
                }
                .onChange(of: images) { _ in
                    Task {
                        selectedIndex = self.images.count
                    }
                }
            }
        }
        .tint(.mainBlack)
    }
    
    private func updateImage() async {
        guard !selectedPhotos.isEmpty else {
            self.images = []
            return
        }
        var images = [UIImage]()
        for selectedPhoto in selectedPhotos {
            do {
                guard let data = try await selectedPhoto.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: data) else {
                    throw ImageLoadingError.invalidImageData
                }
                images.append(uiImage)
            } catch let error {
                print("Error loading image: \(error.localizedDescription)")
            }
        }
        self.images = images
        self.selectedIndex = self.images.count
    }
    
    private func removePhoto(_ index: Int) {
        self.images.remove(at: index)
        self.selectedPhotos.remove(at: index)
    }
}

//#Preview {
//    PhotoSelectPagingTab()
//}

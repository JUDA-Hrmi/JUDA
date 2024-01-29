//
//  ImageSelectHorizontalScroll.swift
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

struct ImageSelectHorizontalScroll: View {
    // photo picker sheet 프로퍼티
    @State private var isLibraryPresented = false
    // 현재 선택된 탭의 인덱스. 초기값 0
    @State private var selectedIndex = 0
    // photo picker로 선택된 이미지 배열
    @Binding var selectedPhotos: [UIImage?]
    
    var body: some View {
        // MARK: 해당 부분 삭제 논의
        VStack(alignment: .leading) {
            HStack(alignment: .lastTextBaseline) {
                Text("사진 등록")
                    .font(.regular16)
                Text("(최대 10장)")
                    .font(.regular14)
                    .foregroundStyle(.gray01)
            }

            HStack {
                // 선택된 사진들을 탭뷰 페이징 형식으로 보여주기
                TabView(selection: $selectedIndex) {
                    ForEach($selectedPhotos.indices, id: \.self) { index in
                        // selectedPhotos의 요소가 nil이 아닌 경우, 이미지 보여주기
                        if selectedPhotos[index] != nil {
                            ImageView(image: $selectedPhotos[index],
                                      selectedPhotos: $selectedPhotos,
                                      currentIndex: index)
                            .tag(index)
                        }
                    }
                    // selectedPhotos에 사진을 선택할 수 있는 잔여 공간이 남아있는 경우, + 버튼 활성화
                    if selectedPhotos.contains(nil) {
                        Image(systemName: "plus.circle.fill")
                            .font(.largeTitle)
                            .frame(width: 350, height: 350)
                            .background(.gray06)
                            .tag(selectedPhotos.endIndex + 1)
                            .onTapGesture {
                                isLibraryPresented.toggle()
                            }
                    }
                }
                .frame(height: 350)
                .tabViewStyle(.page)
            }
        }
        .sheet(isPresented: $isLibraryPresented) {
            let remainingSpaces = getRemainigSpaces()
            PhotoPicker(selectedPhotos: $selectedPhotos,
                        isLibraryPresented: $isLibraryPresented,
                        remainingSpaces: remainingSpaces)
        }
        // selectedPhotos에 사진이 추가될 때, 탭뷰 selectedIndex를 마지막 사진의 인덱스로 변경
        .onChange(of: selectedPhotos) { newValue in
            if let index = newValue.lastIndex(where: { $0 != nil }) {
                selectedIndex = index
            }
        }
    }
    
    private func getRemainigSpaces() -> Int {
        return selectedPhotos.filter { $0 == nil }.count
    }
}

struct ImageView: View {
    @Binding var image: UIImage?
    @Binding var selectedPhotos: [UIImage?]
    var currentIndex: Int
    
    var body: some View {
        Image(uiImage: image!)
            .resizable()
            .aspectRatio(contentMode: .fill)
            // TODO: frame 수정
            .frame(width: 350, height: 350)
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
    
    private func removePhoto() {
        self.selectedPhotos.remove(at: currentIndex)
        selectedPhotos.append(nil)
    }
}

//#Preview {
//    ImageSelectHorizontalScroll()
//}

//
//  PostPhotoScroll.swift
//  JUDA
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

struct PostPhotoScroll: View {
    @State private var selectedIndex = 0
    @State private var isFullSizePhotoPresented = false
    
	let postPhotos: [String]
	
    var body: some View {
		// 사진 페이징 스크롤 형식
		TabView(selection: $selectedIndex) {
			ForEach(0..<postPhotos.count, id: \.self) { index in
				Image(postPhotos[index])
					.resizable()
					.aspectRatio(1.0, contentMode: .fill)
					.onTapGesture {
						isFullSizePhotoPresented = true
					}
			}
		}
		.frame(height: 350)
		.padding(.bottom, 10)
		.tabViewStyle(.page)
		
		// 사진을 탭했을 시, 전체화면에서 사진의 원본 비율로 보여주는 뷰
		.fullScreenCover(isPresented: $isFullSizePhotoPresented) {
			ZStack(alignment: .topTrailing) {
				Color.black
				
				TabView(selection: $selectedIndex) {
					ForEach(0..<postPhotos.count, id: \.self) { index in
						Image(postPhotos[index])
					}
				}
				.tabViewStyle(.page)
				
				Button {
					// X버튼 탭 할 경우 해당 뷰 내려줌
					isFullSizePhotoPresented = false
				} label: {
					Image(systemName: "xmark")
						.foregroundStyle(.gray01)
						.font(.bold20)
						.padding(.top, 30)
				}
				.padding(30)
			}
			.ignoresSafeArea()
		}
    }
}

#Preview {
	PostPhotoScroll(postPhotos: ["foodEx1", "foodEx2", "foodEx3", "foodEx4"])
}

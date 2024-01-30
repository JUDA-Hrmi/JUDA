//
//  PostPhotoScroll.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

struct PostPhotoScroll: View {
	
	let postPhotos: [String]
	
	@State private var selectedIndex = 0
	@State private var isFullSizePhotoPresented = false
	
    var body: some View {
		TabView(selection: $selectedIndex) {
			ForEach(0..<postPhotos.count, id: \.self) { index in
				Image(postPhotos[index])
					.resizable()
					.aspectRatio(contentMode: .fill)
					.clipped()
					.onTapGesture {
						isFullSizePhotoPresented = true
					}
			}
		}
		.frame(height: 350)
		.padding(.bottom, 10)
		.tabViewStyle(.page)
		.fullScreenCover(isPresented: $isFullSizePhotoPresented) {
			ZStack(alignment: .topLeading) {
				Color.black
				
				TabView(selection: $selectedIndex) {
					ForEach(0..<postPhotos.count, id: \.self) { index in
						Image(postPhotos[index])
					}
				}
				.tabViewStyle(.page)
				
				Button {
					isFullSizePhotoPresented = false
				} label: {
					Image(systemName: "xmark")
						.foregroundStyle(.gray01)
						.font(.bold20)
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

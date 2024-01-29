//
//  PostPhotoScroll.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

struct PostPhotoScroll: View {
	
	let postPhotos: [String]
	
    var body: some View {
		TabView {
			ForEach(0..<postPhotos.count, id: \.self) { index in
				Image(postPhotos[index])
					.resizable()
					.aspectRatio(contentMode: .fill)
					.clipped()
			}
		}
		.frame(height: 350)
		.padding(.bottom, 10)
		.tabViewStyle(.page)
    }
}

#Preview {
	PostPhotoScroll(postPhotos: ["foodEx1", "foodEx2", "foodEx3", "foodEx4"])
}

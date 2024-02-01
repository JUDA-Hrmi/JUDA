//
//  PostGrid.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/30/24.
//

import SwiftUI

struct PostGrid: View {
	
	@Binding var isLike: Bool
	@Binding var likeCount: Int
	
	let postUserType: PostUserType
	
	@State private var scrollAxis: Axis.Set = .vertical
	@State private var vHeight = 0.0
	
    var body: some View {
		// TODO: navigationLink 및 navigationDestination을 통한 RecordDetailView 전환 구현
		CustomScrollView(scrollAxis: $scrollAxis, vHeight: $vHeight) {
			LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
				ForEach(0..<12, id: \.self) { _ in
					NavigationLink {
						PostDetailView(postUserType: postUserType,
									   nickName: "hrmi",
									   isLike: $isLike,
									   likeCount: $likeCount)
					} label: {
						PostCell(isLike: $isLike, likeCount: $likeCount)
					}
					.buttonStyle(EmptyActionStyle())
				}
			}
		}
		.padding(.horizontal, 20)
		.refreshable {
			// TODO: write post data refresh code
		}
    }
}

#Preview {
	PostGrid(isLike: .constant(false), likeCount: .constant(45), postUserType: PostUserType.reader)
}

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
	
    var body: some View {
		// TODO: navigationLink 및 navigationDestination을 통한 RecordDetailView 전환 구현
		ScrollView {
			LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
				ForEach(0..<12, id: \.self) { _ in
					NavigationLink {
//								PostDetailView(isLike: $isLike, likeCount: $likeCount)
					} label: {
						PostCell(isLike: $isLike, likeCount: $likeCount)
					}
					.buttonStyle(EmptyActionStyle())
				}
			}
		}
		.padding(.horizontal, 20)
		.scrollIndicators(.hidden)
		.refreshable {
			// TODO: write post data refresh code
		}
    }
}

#Preview {
	PostGrid(isLike: .constant(false), likeCount: .constant(45))
}

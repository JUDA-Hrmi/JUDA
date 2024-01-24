//
//  CustomTextSegment.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/25/24.
//

import SwiftUI

enum PostOrLiked {
	case post, liked
	
	var segments: [String] {
		switch self {
		case .post:
			return ["인기", "최신"]
		case .liked:
			return ["술상 리스트", "술찜 리스트"]
		}
	}
}

struct CustomTextSegment: View {
	
	let segments: [String]
	@Binding var selected: String
	@Namespace var name
	
	var body: some View {
		HStack(spacing: 20) {
			ForEach(segments, id: \.self) { segment in
				Button {
					selected = segment
				} label: {
					VStack {
						Text(segment)
							.font(.medium14)
							.foregroundColor(selected == segment ? .mainBlack : .gray01)
						ZStack {
							Capsule()
								.fill(Color.clear)
								.frame(height: 3)
							if selected == segment {
								Capsule()
									.fill(.mainBlack)
									.frame(height: 3)
									.matchedGeometryEffect(id: "Tab", in: name)
							}
						}
					}
				}
			}
		}
		.fixedSize()
	}
}

//#Preview {
//	CustomTextSegment()
//}

//
//  PostTags.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

struct PostTags: View {
	
	let tags: [String]
	let windowWidth: CGFloat
	
    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			ForEach(TagHandler.getRows(tags: tags,
									   spacing: 15,
									   fontSize: 14,
									   windowWidth: windowWidth,
									   tagString: "# "), id: \.self) { row in
				NavigationLink {
					// TODO: PostView Linking code
				} label: {
					HStack(spacing: 15) {
						ForEach(row, id: \.self) { tag in
							Text("# \(tag)")
								.font(.semibold14)
								.foregroundStyle(.mainAccent04)
						}
					}
				}
			}
		}
		.frame(width: windowWidth, alignment: .leading)
    }
}

//#Preview {
//    PostTags()
//}

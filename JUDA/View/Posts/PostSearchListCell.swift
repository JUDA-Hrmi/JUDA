//
//  PostSearchListCell.swift
//  JUDA
//
//  Created by Minjae Kim on 2/26/24.
//

import SwiftUI

struct PostSearchListCell: View {
	let searchTagType: SearchTagType
	let searchText: String
	let postCount: Int
	var body: some View {
		VStack(spacing: 20) {
			HStack(alignment: .firstTextBaseline) {
				Text("\(searchTagType.rawValue)")
					.font(.regular18)
					.foregroundStyle(.mainBlack)
				Text("'\(searchText)'")
					.font(.medium20)
					.foregroundStyle(.mainBlack)
				HStack(spacing: 0) {
					Text("\(postCount)")
						.font(.regular20)
						.foregroundStyle(.mainAccent03)
					Text("개")
						.font(.regular20)
						.foregroundStyle(.mainBlack)
				}
				Image(systemName: "chevron.right")
					.foregroundStyle(.mainBlack)
				
				Spacer()
			}
			CustomDivider()
		}
	}
}

#Preview {
	PostSearchListCell(searchTagType: .userName, searchText: "망재", postCount: 20)
}

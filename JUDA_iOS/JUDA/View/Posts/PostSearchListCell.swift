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
					.font(.regular16)
				Text("'\(searchText)'")
					.font(.medium16)
				HStack(spacing: 0) {
					Text("\(postCount)")
						.font(.regular16)
						.foregroundStyle(.mainAccent03)
					Text("개")
						.font(.regular16)
				}
				Image(systemName: "chevron.right")
				
				Spacer()
			}
			CustomDivider()
		}
	}
}

#Preview {
	PostSearchListCell(searchTagType: .userName, searchText: "망재", postCount: 20)
}

//
//  NavigationPostView.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/31/24.
//

import SwiftUI

struct NavigationPostsView: View {
	@Environment(\.dismiss) var dismiss
	
	@Binding var postSearchText: String
	
	var body: some View {
		PostsView(postSearchText: $postSearchText)
		.navigationBarBackButtonHidden()
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Button {
					// TODO: NavigationStack path remove
					dismiss()
				} label: {
					Image(systemName: "chevron.left")
						.foregroundStyle(.mainBlack)
				}
			}
		}
	}
}

#Preview {
	NavigationPostsView(postSearchText: .constant(""))
}

//
//  PostSearchList.swift
//  JUDA
//
//  Created by Minjae Kim on 2/26/24.
//

import SwiftUI

struct PostSearchList: View {
	@EnvironmentObject private var searchPostsViewModel: SearchPostsViewModel
	let searchText: String
    var body: some View {
		VStack(spacing: 20) {
			NavigationLink {
				NavigationPostsView(usedTo: .postSearch, searchTagType: .userName)
			} label: {
				PostSearchListCell(searchTagType: .userName,
								   searchText: searchText,
								   postCount: searchPostsViewModel.searchPostsByUserName.count)
			}
			.disabled(searchPostsViewModel.searchPostsByUserName.isEmpty)

			NavigationLink {
				NavigationPostsView(usedTo: .postSearch, searchTagType: .drinkTag)
			} label: {
				PostSearchListCell(searchTagType: .drinkTag,
								   searchText: searchText,
								   postCount: searchPostsViewModel.searchPostsByDrinkTag.count)
			}
			.disabled(searchPostsViewModel.searchPostsByDrinkTag.isEmpty)
			
			NavigationLink {
				NavigationPostsView(usedTo: .postSearch, searchTagType: .foodTag)
			} label: {
				PostSearchListCell(searchTagType: .foodTag,
								   searchText: searchText,
								   postCount: searchPostsViewModel.searchPostsByFoodTag.count)
			}
			.disabled(searchPostsViewModel.searchPostsByFoodTag.isEmpty)
			Spacer()
		}
		.padding(20)
    }
}

//#Preview {
//	PostSearchList(searchText: "망재")
//}

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
            NavigationLink(value: Route
                .NavigationPostsTo(usedTo: .postSearch,
                                   searchTagType: .userName)) {
                PostSearchListCell(searchTagType: .userName,
                                   searchText: searchText,
                                   postCount: searchPostsViewModel.searchPostsByUserName.count)
            }
            .disabled(searchPostsViewModel.searchPostsByUserName.isEmpty)
            .foregroundStyle(searchPostsViewModel.searchPostsByUserName.isEmpty ? .gray01 : .mainBlack)

            NavigationLink(value: Route
                .NavigationPostsTo(usedTo: .postSearch,
                                   searchTagType: .drinkTag)) {
                PostSearchListCell(searchTagType: .drinkTag,
                                   searchText: searchText,
                                   postCount: searchPostsViewModel.searchPostsByDrinkTag.count)
            }
            .disabled(searchPostsViewModel.searchPostsByDrinkTag.isEmpty)
            .foregroundStyle(searchPostsViewModel.searchPostsByDrinkTag.isEmpty ? .gray01 : .mainBlack)

            NavigationLink(value: Route
                .NavigationPostsTo(usedTo: .postSearch,
                                   searchTagType: .foodTag)) {
                PostSearchListCell(searchTagType: .foodTag,
                                   searchText: searchText,
                                   postCount: searchPostsViewModel.searchPostsByFoodTag.count)
            }
            .disabled(searchPostsViewModel.searchPostsByFoodTag.isEmpty)
            .foregroundStyle(searchPostsViewModel.searchPostsByFoodTag.isEmpty ? .gray01 : .mainBlack)
            Spacer()
        }
        .padding(20)
    }
}

//
//  PostDrinkRating.swift
//  JUDA
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

// MARK: - 술상 디테일에서, 술 평가
struct PostDrinkRating: View {
    @EnvironmentObject private var drinkViewModel: DrinkViewModel
	@State private var taggedDrinks = [Drink]()
    let post: Post
	
    var body: some View {
		VStack(spacing: 20) {
            // 술 평가 텍스트
            Text("\(post.postField.user.userName)의 술평가")
                .font(.bold16)
                .frame(maxWidth: .infinity, alignment: .leading)
            // 각 술 이름 + 평점
            ForEach(taggedDrinks, id:\.drinkField.drinkID) { drink in
                NavigationLink(value: Route
                    .DrinkDetailWithUsedTo(drink: drink,
                                           usedTo: .post)) {
                    HStack(spacing: 2) {
                        // 술 이름
                        Text(drink.drinkField.name)
                            .font(.semibold16)
                            .lineLimit(1)
                        Spacer()
                        // 술 평가 별점
                        HStack(spacing: 5) {
                            StarRating(rating: drinkViewModel.getDrinkRating(drinkTags: post.postField.drinkTags,
                                                                             drink: drink),
                                       color: .mainAccent02,
                                       starSize: .regular16, 
                                       fontSize: .semibold14,
                                       starRatingType: .withText)
                            Image(systemName: "chevron.forward")
                        }
                    }
                    .foregroundStyle(.mainBlack)
                    .padding(.horizontal, 10)
                }
			}
		}
        .task {
            taggedDrinks = await drinkViewModel.getPostTaggedDrinks(
                drinksID: post.postField.drinkTags.map { $0.drinkID }
            )
        }
    }
}

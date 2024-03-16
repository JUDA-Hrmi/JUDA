//
//  PostDrinkRating.swift
//  JUDA
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

// MARK: - 술상 디테일에서, 술 평가
struct PostDrinkRating: View {
	let post: Post
	
    var body: some View {
		VStack(spacing: 20) {
            // 술 평가 텍스트
			Text("\(post.userField.name)의 술평가")
                .font(.bold16)
                .frame(maxWidth: .infinity, alignment: .leading)
            // 각 술 이름 + 평점
			ForEach(post.drinkTags ?? [], id:\.drink.drinkID) { drinkTag in
                NavigationLink(value: Route
                    .DrinkDetailWithUsedTo(drink: drinkTag.drink,
                                           usedTo: .post)) {
                    HStack(spacing: 2) {
                        // 술 이름
                        Text(drinkTag.drink.name)
                            .font(.semibold16)
                            .lineLimit(1)
                        Spacer()
                        // 술 평가 별점
                        HStack(spacing: 5) {
                            StarRating(rating: drinkTag.rating, color: .mainAccent02, starSize: .regular16, fontSize: .semibold14, starRatingType: .withText)
                            Image(systemName: "chevron.forward")
                        }
                    }
                    .foregroundStyle(.mainBlack)
                    .padding(.horizontal, 10)
                }
			}
		}
    }
}

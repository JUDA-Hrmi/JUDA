//
//  PostDrinkRating.swift
//  JUDA
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

// MARK: - 술상 디테일에서, 술 평가
struct PostDrinkRating: View {
	let userName: String
	let postDrinks: [String]
	let postDrinksStarRating: [Double]
	
    var body: some View {
		VStack(spacing: 20) {
            // 술 평가 텍스트
            Text("\(userName)의 술평가")
                .font(.bold16)
                .frame(maxWidth: .infinity, alignment: .leading)
            // 각 술 이름 + 평점
			ForEach(0..<postDrinks.count, id:\.self) { index in
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
					DrinkDetailView()
                        .modifier(TabBarHidden())
				} label: {
					HStack(spacing: 2) {
                        // 술 이름
						Text(postDrinks[index])
							.font(.semibold16)
							.lineLimit(1)
						Spacer()
						// 술 평가 별점
						HStack(spacing: 5) {
							StarRating(rating: postDrinksStarRating[index], color: .mainAccent02, starSize: .regular16, fontSize: .semibold14, starRatingType: .withText)
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

#Preview {
	PostDrinkRating(userName: "hrmi",
					postDrinks: ["카누카 칵테일 700ml", "글렌알라키 10년 캐스크 스트래쓰 700ml", "카누카 칵테일 700ml"],
					postDrinksStarRating: [4.5, 4.0, 5.0])
}

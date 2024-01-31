//
//  PostDrinkRating.swift
//  FinalHrmiProjects
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

struct PostDrinkRating: View {
	
	let userName: String
	let postDrinks: [String]
	let postDrinksStarRating: [Double]
	
    var body: some View {
		VStack(spacing: 20) {
			HStack {
				Text("\(userName)의 술평가")
					.font(.bold16)
				Spacer()
			}
			ForEach(0..<postDrinks.count, id:\.self) { index in
				NavigationLink {
					// TODO: DrinkInfoView Linking code
					DrinkDetailView()
				} label: {
					HStack(spacing: 2) {
						Text(postDrinks[index])
							.font(.semibold16)
							.lineLimit(1)
						Spacer()
						
						// TODO: need StarRating code modify
						let rating = postDrinksStarRating[index]
						let fullStars = Int(rating)
						let hasHalfStar = (rating - Double(fullStars)) >= 0.5
						HStack(spacing: 5) {
							HStack(spacing: 0) {
								ForEach(0..<5) { index in
									Image(systemName: index < fullStars ? "star.fill" : (hasHalfStar && index == fullStars ? "star.leadinghalf.filled" : "star"))
										.foregroundStyle(.mainAccent03)
								}
							}
							Text(String(format: "%.1F", postDrinksStarRating[index]))
								.font(.semibold14)
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

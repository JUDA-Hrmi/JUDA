//
//  DrinkGridCell.swift
//  JUDA
//
//  Created by phang on 1/25/24.
//

import SwiftUI

// MARK: - 술 그리드 셀
struct DrinkGridCell: View {
    // UITest - Drink DummyData
    private let drinkImage = "canuca"
    private let drinkName = "카누카 칵테일 700ml"
    private let drinkOrigin = "스페인"
    private let drinkABV: Double = 15
    private let drinkRating = 4.7
    // UITest - Drink 하트
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            // 하트
            Button {
                isLiked.toggle()
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? .mainAccent02 : .gray01)
            }
            // 술 정보
            VStack(alignment: .leading, spacing: 10) {
                // 술 사진
                VStack(alignment: .center) {
                    Image(drinkImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 103.48)
                        .frame(width: 70)
                }
                .frame(maxWidth: .infinity)
                // 술 이름
                Text(drinkName)
                    .lineLimit(2)
                    .font(.semibold16)
                    .foregroundStyle(.mainBlack)
                // 나라, 도수
                HStack(spacing: 10) {
                    Text(drinkOrigin)
                        .font(.semibold14)
                    Text(Formatter.formattedABVCount(abv: drinkABV))
                        .font(.semibold14)
                }
                .foregroundStyle(.gray01)
                // 별점
                VStack(spacing: 0) {
                    Spacer()
                    // 별
                    StarRating(rating: drinkRating, 
                               color: .mainAccent05,
                               starSize: .semibold14, 
                               fontSize: .semibold14,
                               starRatingType: .withText)
                }
            }
        }
        .padding(10)
        .frame(height: 280)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
        ForEach(0..<3, id: \.self) { _ in
            DrinkGridCell()
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
}

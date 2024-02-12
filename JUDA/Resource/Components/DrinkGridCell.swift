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
    let drink: Drink
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
                    Image(drink.image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 103.48)
                        .frame(width: 70)
                }
                .frame(maxWidth: .infinity)
                // 술 이름 + 용량
                Text(drink.name + " " + drink.amount)
                    .lineLimit(2)
                    .font(.semibold16)
                    .foregroundStyle(.mainBlack)
                // 나라, 도수
                switch drink.drinkType {
                case .wine:
                    getCountryAndProvinceAndABV(drink as! Wine)
                default:
                    getCountryAndABV(drink)
                }
                // 별점
                VStack(spacing: 0) {
                    Spacer()
                    // 별
                    StarRating(rating: drink.rating,
                               color: .mainAccent05,
                               starSize: .semibold14, 
                               fontSize: .semibold14,
                               starRatingType: .withText)
                }
            }
        }
        .padding(10)
        .frame(height: 270)
    }
    
    @ViewBuilder
    private func getCountryAndABV(_ drink: Drink) -> some View {
        HStack(spacing: 10) {
            Text(drink.country)
                .font(.semibold14)
            Text(Formatter.formattedABVCount(abv: drink.abv))
                .font(.semibold14)
        }
        .foregroundStyle(.gray01)
    }
    
    @ViewBuilder
    private func getCountryAndProvinceAndABV(_ drink: Wine) -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 6) {
                Text(drink.country)
                    .font(.semibold14)
                Text(drink.province)
                    .font(.semibold14)
            }
            Text(Formatter.formattedABVCount(abv: drink.abv))
                .font(.semibold14)
        }
        .foregroundStyle(.gray01)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
        ForEach(0..<3, id: \.self) { _ in
            DrinkGridCell(drink: Korean.koreanSample01)
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
}

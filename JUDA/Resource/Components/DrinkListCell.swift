//
//  DrinkListCell.swift
//  JUDA
//
//  Created by phang on 1/25/24.
//

import SwiftUI

// MARK: - 술 리스트 셀
struct DrinkListCell: View {
    // UITest - Drink DummyData
    let drink: FBDrink
    // UITest - Drink 하트
    @Binding var isLiked: Bool
    // searchTagView에서 사용하는지에 대한 여부
    var searchTag: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            // 술 정보
            HStack(alignment: .center, spacing: 20) {
                // 술 사진
                Image("jinro")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 103.48)
                    .frame(width: 70)
                // 술 이름 + 나라, 도수 + 별점
                VStack(alignment: .leading, spacing: 10) {
                    // 술 이름 + 용량
                    Text(drink.name + " " + drink.amount)
                        .lineLimit(2)
                        .font(.semibold16)
                        .foregroundStyle(.mainBlack)
                    // 나라, 도수
                    HStack(spacing: 0) {
                        Text(drink.country)
                            .font(.semibold14)
//                        if drink.drinkType == .wine ,let wine = drink as? Wine {
                        if drink.category == DrinkType.wine.rawValue,
                           let province = drink.province {
                            Text(province)
                                .font(.semibold14)
                                .padding(.leading, 6)
                        }
                        Text(Formatter.formattedABVCount(abv: drink.alcohol))
                            .font(.semibold14)
                            .padding(.leading, 10)
                    }
                    .foregroundStyle(.gray01)
                    // 별점
                    StarRating(rating: drink.rating,
                               color: .mainAccent05,
                               starSize: .semibold14, 
                               fontSize: .semibold14,
                               starRatingType: .withText)
                }
            }
            Spacer()
            // 하트
            // searchTagView에서 사용 시, 버튼이 아닌 이미지 처리
            if searchTag {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? .mainAccent02 : .gray01)
            } else {
                Button {
                    isLiked.toggle()
                } label: {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundStyle(isLiked ? .mainAccent02 : .gray01)
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .frame(height: 130)
    }
}

//#Preview {
//    DrinkListCell(drink: Wine.wineSample01)
//}

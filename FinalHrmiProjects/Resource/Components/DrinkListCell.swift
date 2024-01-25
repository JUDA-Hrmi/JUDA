//
//  DrinkListCell.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/25/24.
//

import SwiftUI

struct DrinkListCell: View {
    // UITest - Drink DummyData
    private let drinkImage = "canuca"
    private let drinkName = "카누카 칵테일 700ml"
    private let drinkOrigin = "스페인"
    private let drinkABV = "15%"
    private let drinkRating = "4.7"
    // UITest - Drink 하트
    @State private var isLiked = false
    
    var body: some View {
        HStack(alignment: .top) {
            // 술 정보
            HStack(alignment: .center, spacing: 20) {
                // 술 사진
                Image(drinkImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 103.48)
                    .frame(width: 70)
                // 술 이름 + 나라, 도수 + 별점
                VStack(alignment: .leading, spacing: 10) {
                    // 술 이름
                    Text(drinkName)
                        .lineLimit(2)
                        .font(.semibold16)
                        .foregroundStyle(.mainBlack)
                    // 나라, 도수
                    HStack(spacing: 10) {
                        Text(drinkOrigin)
                            .font(.semibold14)
                        Text(drinkABV)
                            .font(.semibold14)
                    }
                    .foregroundStyle(.gray01)
                    // 별점
                    HStack(alignment: .center, spacing: 6) {
                        // 별
                        HStack(alignment: .center, spacing: 0) {
                            // TODO: 추후 커스텀 별로 이미지 교체 예정
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.leadinghalf.filled")
                        }
                        .foregroundStyle(.mainAccent05)
                        // 별점
                        Text(drinkRating)
                            .font(.semibold14)
                            .foregroundStyle(.mainBlack)
                    }
                }
            }
            Spacer()
            // 하트
            Button {
                isLiked.toggle()
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? .mainAccent02 : .gray01)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .frame(height: 130)
    }
}

#Preview {
    DrinkListCell()
}

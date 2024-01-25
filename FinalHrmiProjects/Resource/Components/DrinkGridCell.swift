//
//  DrinkGridCell.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/25/24.
//

import SwiftUI

struct DrinkGridCell: View {
    // UITest - Drink DummyData
    private let drinkImage = "canuca"
    private let drinkName = "카누카 칵테일 700ml"
    private let drinkOrigin = "스페인"
    private let drinkABV = "15%"
    private let drinkRating = "4.7"
    // UITest - Drink 하트
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            // 하트
            Button {
                isLiked.toggle()
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? Color.mainAccent02 : Color.gray01)
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
                    Text(drinkABV)
                        .font(.semibold14)
                }
                .foregroundStyle(.gray01)
                // 별점
                VStack(spacing: 0) {
                    Spacer()
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

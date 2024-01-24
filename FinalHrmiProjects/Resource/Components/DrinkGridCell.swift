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
                    .foregroundStyle(isLiked ? Color.red : Color.gray)
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
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.black)
                // 나라, 도수
                HStack(spacing: 10) {
                    Text(drinkOrigin)
                        .font(.system(size: 14, weight: .semibold))
                    Text(drinkABV)
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(.gray)
                // 별점
                VStack(spacing: 0) {
                    Spacer()
                    HStack(alignment: .center, spacing: 6) {
                        // 별
                        HStack(alignment: .center, spacing: 0) {
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.fill")
                            Image(systemName: "star.leadinghalf.filled")
                        }
                        .foregroundStyle(.yellow)
                        // 별점
                        Text(drinkRating)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.black)
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

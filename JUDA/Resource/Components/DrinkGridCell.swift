//
//  DrinkGridCell.swift
//  JUDA
//
//  Created by phang on 1/25/24.
//

import SwiftUI

// MARK: - 술 그리드 셀
struct DrinkGridCell: View {
    let drink: FBDrink
    
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
//                    Image(drink.image)
                    Image("jinro")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 103.48)
                        .frame(width: 70)
                }
                .frame(maxWidth: .infinity)
                // 술 이름 + 용량
                Text(drink.name + " " + drink.amount)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .font(.semibold16)
                    .foregroundStyle(.mainBlack)
                // 나라, 도수
                switch drink.category {
                case DrinkType.wine.rawValue:
                    getCountryAndProvinceAndABV()
                default:
                    getCountryAndABV()
                }
                Spacer()
                // 별
                StarRating(rating: drink.rating,
                           color: .mainAccent05,
                           starSize: .semibold14,
                           fontSize: .semibold14,
                           starRatingType: .withText)
            }
        }
        .frame(height: 270)
        .padding(10)
    }
    
    @ViewBuilder
    private func getCountryAndABV() -> some View {
        HStack(spacing: 10) {
            Text(drink.country)
                .font(.semibold14)
            Text(Formatter.formattedABVCount(abv: drink.alcohol))
                .font(.semibold14)
        }
        .foregroundStyle(.gray01)
    }
    
    @ViewBuilder
    private func getCountryAndProvinceAndABV() -> some View {
        VStack(alignment: .leading) {
            HStack(spacing: 6) {
                Text(drink.country)
                    .font(.semibold14)
                Text(drink.province ?? "")
                    .font(.semibold14)
            }
            Text(Formatter.formattedABVCount(abv: drink.alcohol))
                .font(.semibold14)
        }
        .foregroundStyle(.gray01)
    }
}

// MARK: - 로딩 중, 술 리스트 셀
struct ShimmerDrinkGridCell: View {
    @State private var show: Bool = false
    
    var body: some View {
        ZStack {
            // shimmer view
            VStack(alignment: .trailing, spacing: 10) {
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(.black.opacity(0.09))
                    .frame(width: 26, height: 26)
                // 술 정보
                VStack(alignment: .leading, spacing: 10) {
                    // 술 사진
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.black.opacity(0.09))
                            .frame(height: 103.48)
                            .frame(width: 70)
                    }
                    .frame(maxWidth: .infinity)
                    // 술 이름 + 용량
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black.opacity(0.09))
                        .frame(width: 130, height: 15)
                    // 나라, 도수
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black.opacity(0.09))
                        .frame(width: 100, height: 15)
                    Spacer()
                    // 별
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.black.opacity(0.09))
                        .frame(width: 80, height: 15)
                }
            }
            // shimmer animation view
            VStack(alignment: .trailing, spacing: 10) {
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.6))
                    .frame(width: 26, height: 26)
                // 술 정보
                VStack(alignment: .leading, spacing: 10) {
                    // 술 사진
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.white.opacity(0.6))
                            .frame(height: 103.48)
                            .frame(width: 70)
                    }
                    .frame(maxWidth: .infinity)
                    // 술 이름 + 용량
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.6))
                        .frame(width: 130, height: 15)
                    // 나라, 도수
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.6))
                        .frame(width: 100, height: 15)
                    Spacer()
                    // 별
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white.opacity(0.6))
                        .frame(width: 80, height: 15)
                }
            }
            .mask {
                RoundedRectangle(cornerRadius: 10)
                    .fill(.white.opacity(0.6))
                    .rotationEffect(.init(degrees: 20))
                    .offset(x: show ? 800 : -150)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    show.toggle()
                }
            }
        }
        .frame(height: 270)
        .padding(10)
    }
}

#Preview {
    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
        ForEach(0..<3, id: \.self) { _ in
//            DrinkGridCell(drink: FBDrink.dummyData)
            ShimmerDrinkGridCell()
        }
    }
    .padding(.horizontal, 20)
    .padding(.vertical, 10)
}

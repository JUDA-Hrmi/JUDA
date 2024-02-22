//
//  DrinkGridCell.swift
//  JUDA
//
//  Created by phang on 1/25/24.
//

import SwiftUI
import Kingfisher

// MARK: - 술 그리드 셀
struct DrinkGridCell: View {
    @EnvironmentObject private var drinkViewModel: DrinkViewModel
    @State private var imageString: String = ""
    @State private var isLoading: Bool = true
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
                    if isLoading {
                        KFImage(URL(string: imageString))
                            .placeholder {
                                CircularLoaderView(size: 20)
                                    .frame(width: 70, height: 103.48)
                            }
                            .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
                            .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
                            .fade(duration: 0.2) // 이미지 부드럽게 띄우기
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 70, height: 103.48)
                    } else {
                        Text("No Image")
                            .font(.medium16)
                            .foregroundStyle(.mainBlack)
                            .frame(width: 70, height: 103.48)
                    }
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
        // 이미지 불러오기
        .task {
            if let imageName = drinkViewModel.getImageName(
                                category: DrinkType(rawValue: drink.category) ?? DrinkType.all,
                                detailedCategory: drink.type) {
                if let imageString = await drinkViewModel.fetchImageUrl(imageName: imageName) {
                    self.imageString = imageString
                } else {
                    self.isLoading = false
                }
            } else {
                self.isLoading = false
            }
        }
    }
    
    @ViewBuilder
    private func getCountryAndABV() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text(drink.type)
                Text(Formatter.formattedABVCount(abv: drink.alcohol))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            Text(drink.country)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.semibold14)
        .foregroundStyle(.gray01)
    }
    
    @ViewBuilder
    private func getCountryAndProvinceAndABV() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 6) {
                Text(drink.type)
                Text(Formatter.formattedABVCount(abv: drink.alcohol))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            HStack(spacing: 6) {
                Text(drink.country)
                Text(drink.province ?? "")
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .font(.semibold14)
        .foregroundStyle(.gray01)
    }
}

// MARK: - 로딩 중, 술 리스트 셀
struct ShimmerDrinkGridCell: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var show: Bool = false
    private var overColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    var body: some View {
        ZStack {
            // shimmer view
            VStack(alignment: .trailing, spacing: 10) {
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBlack.opacity(0.09))
                    .frame(width: 26, height: 26)
                // 술 정보
                VStack(alignment: .leading, spacing: 10) {
                    // 술 사진
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 70, height: 103.48)
                    }
                    .frame(maxWidth: .infinity)
                    // 술 이름 + 용량
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 130, height: 15)
                    // 나라, 지방
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 100, height: 15)
                    // 타입, 도수
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 100, height: 15)
                    Spacer()
                    // 별
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 80, height: 15)
                }
            }
            // shimmer animation view
            VStack(alignment: .trailing, spacing: 10) {
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .frame(width: 26, height: 26)
                // 술 정보
                VStack(alignment: .leading, spacing: 10) {
                    // 술 사진
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 70, height: 103.48)
                    }
                    .frame(maxWidth: .infinity)
                    // 술 이름 + 용량
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 130, height: 15)
                    // 나라, 지방
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 100, height: 15)
                    // 타입, 도수
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 100, height: 15)
                    Spacer()
                    // 별
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 80, height: 15)
                }
            }
            .mask {
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
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

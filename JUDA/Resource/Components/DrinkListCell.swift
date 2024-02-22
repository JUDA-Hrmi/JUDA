//
//  DrinkListCell.swift
//  JUDA
//
//  Created by phang on 1/25/24.
//

import SwiftUI
import Kingfisher

// MARK: - 술 리스트 셀
struct DrinkListCell: View {
    @EnvironmentObject private var drinkViewModel: DrinkViewModel
    @State private var imageString: String = ""
    @State private var isLoading: Bool = true
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
}

// MARK: - 로딩 중, 술 리스트 셀
struct ShimmerDrinkListCell: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var show: Bool = false
    private var overColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    var body: some View {
        ZStack {
            // shimmer view
            HStack(alignment: .top) {
                // 술 정보
                HStack(alignment: .center, spacing: 20) {
                    // 술 사진
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 70, height: 103.48)
                    // 술 이름 + 나라, 도수 + 별점
                    VStack(alignment: .leading, spacing: 10) {
                        // 술 이름 + 용량
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 200, height: 15)
                        // 나라, 도수
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 150, height: 15)
                        // 별점
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 120, height: 15)
                    }
                }
                Spacer()
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBlack.opacity(0.09))
                    .frame(width: 26, height: 26)
            }
            // shimmer animation view
            HStack(alignment: .top) {
                // 술 정보
                HStack(alignment: .center, spacing: 20) {
                    // 술 사진
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 70, height: 103.48)
                    // 술 이름 + 나라, 도수 + 별점
                    VStack(alignment: .leading, spacing: 10) {
                        // 술 이름 + 용량
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 200, height: 15)
                        // 나라, 도수
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 150, height: 15)
                        // 별점
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 120, height: 15)
                    }
                }
                Spacer()
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .frame(width: 26, height: 26)
            }
            .mask {
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .rotationEffect(.init(degrees: 120))
                    .offset(x: show ? 800 : -150)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    show.toggle()
                }
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .frame(height: 130)
    }
}

#Preview {
//    DrinkListCell(drink: FBDrink.dummyData)
    ShimmerDrinkListCell()
}

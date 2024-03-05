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
    @EnvironmentObject private var authService: AuthService

    let drink: FBDrink
    @State private var isLiked: Bool = false
    
    private let debouncer = Debouncer(delay: 0.5)
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 10) {
            // 하트
            Button {
                isLiked.toggle()
                // 디바운서 콜
                debouncer.call {
                    authService.addOrRemoveToLikedDrinks(isLiked: isLiked, drink.drinkID)
                    authService.userLikedListUpdate(type: .drinks)
                }
            } label: {
                Image(systemName: isLiked ? "heart.fill" : "heart")
                    .foregroundStyle(isLiked ? .mainAccent02 : .gray01)
            }
            // 술 정보
            VStack(alignment: .leading, spacing: 10) {
                // 술 사진
                VStack(alignment: .center) {
                    if let url = drinkViewModel.drinkImages[drink.drinkID ?? ""] {
                        KFImage.url(url)
                            .placeholder {
                                CircularLoaderView(size: 20)
                                    .frame(width: 70, height: 103.48)
                            }
                            .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
                            .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
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
		.task {
            if let user = authService.currentUser {
                self.isLiked = user.likedDrinks.contains { $0 == drink.drinkID }
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

//
//  DrinkDetails.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI
import Kingfisher

// MARK: - 어느 뷰에서 DrinkDetails 이 사용되는지 enum
enum WhereUsedDrinkDetails {
    case drinkInfo
    case post
    case liked
    case main
}

// MARK: - 술 디테일에서 보여주는 상단의 술 정보 부분 (이미지, 이름, 가격 등)
struct DrinkDetails: View {
    @EnvironmentObject private var navigationRouter: NavigationRouter
    @EnvironmentObject private var mainViewModel: MainViewModel
    @EnvironmentObject private var drinkViewModel: DrinkViewModel
    @EnvironmentObject private var postsViewModel: PostsViewModel
    @EnvironmentObject private var likedViewModel: LikedViewModel
    let drink: FBDrink
    let usedTo: WhereUsedDrinkDetails
    
    var body: some View {
        // 술 정보 (이미지, 이름, 용량, 나라, 도수, 가격, 별점, 태그된 게시물)
        HStack(alignment: .center, spacing: 30) {
            // 술 이미지
            if usedTo == .drinkInfo,
               let url = drinkViewModel.drinkImages[drink.drinkID ?? ""] {
                DrinkDetailsKFImage(url: url)
            } else if usedTo == .liked,
               let url = likedViewModel.drinkImages[drink.drinkID ?? ""] {
                DrinkDetailsKFImage(url: url)
            } else if usedTo == .main,
               let url = mainViewModel.drinkImages[drink.drinkID ?? ""] {
                DrinkDetailsKFImage(url: url)
            } else {
                Text("No Image")
                    .font(.medium16)
                    .foregroundStyle(.mainBlack)
                    .frame(height: 180)
                    .padding(10)
                    .frame(width: 100)
            }
            // 이름, 나라, 도수, 가격, 별점, 태그된 게시물
            VStack(alignment: .leading, spacing: 6) {
                // 이름 + 용량
                Text(drink.name + " " + drink.amount)
                    .font(.semibold18)
                    .foregroundStyle(.mainBlack)
                    .lineLimit(2)
                // 종류, 도수
                HStack {
                    // 종류
                    Text(drink.type)
                    // 도수
                    Text(Formatter.formattedABVCount(abv: drink.alcohol))
                }
                // 나라, 지방
                HStack {
                    // 나라
                    Text(drink.country)
                    if drink.category == DrinkType.wine.rawValue, 
                        let province = drink.province {
                        Text(province) // 지방
                    }
                }
                .font(.regular16)
                // 가격
                Text(Formatter.formattedPriceToString(price: drink.price))
                    .font(.regular16)
                // 별점
                StarRating(rating: drink.rating, color: .mainAccent05,
                           starSize: .regular16, fontSize: .regular16, starRatingType: .withText)
                // 태그된 게시물
                if drink.taggedPostID.count > 0 {
                    NavigationLink(value: Route
                        .NavigationPosts(usedTo: .drinkDetail,
                                         searchTagType: nil,
                                         taggedPostID: drink.taggedPostID,
                                         selectedDrinkName: drink.name,
                                         selectedFoodTag: nil)) {
                        Text("\(drink.taggedPostID.count)개의 태그된 게시물")
                            .font(.regular16)
                            .foregroundStyle(.gray01)
                            .underline()
                    }
                }  else {
                    Text("태그된 게시물 없음")
                        .font(.regular16)
                        .foregroundStyle(.gray01)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

// MARK: - 술 리스트 셀 사용 KingFisher 이미지
struct DrinkDetailsKFImage: View {
    let url: URL
    
    var body: some View {
        KFImage.url(url)
            .placeholder {
                CircularLoaderView(size: 20)
                    .frame(height: 180)
                    .padding(10)
                    .frame(width: 100)
            }
            .loadDiskFileSynchronously(true) // 디스크에서 동기적으로 이미지 가져오기
            .cancelOnDisappear(true) // 화면 이동 시, 진행중인 다운로드 중단
            .cacheMemoryOnly() // 메모리 캐시만 사용 (디스크 X)
            .fade(duration: 0.2) // 이미지 부드럽게 띄우기
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 180)
            .padding(10)
            .frame(width: 100)
    }
}

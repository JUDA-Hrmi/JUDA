//
//  DrinkDetailView.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI
import Kingfisher

// MARK: - 술 디테일 화면
struct DrinkDetailView: View {
    @EnvironmentObject private var drinkViewModel: DrinkViewModel
    @EnvironmentObject private var navigationRouter: NavigationRouter
    
    @State private var windowWidth: CGFloat = 0
    @StateObject var aiWellMatchViewModel = AIWellMatchViewModel() // wellmatch AIModel
    @State private var shareImage: Image = Image("AppIcon") // shareLink 용 이미지

    let drink: FBDrink
    var usedTo: WhereUsedDrinkDetails = .drinkInfo
    
    var body: some View {
        // 세로 스크롤
        ScrollView {
            VStack(spacing: 10) {
                // 술 정보 (이미지, 이름, 나라, 도수, 가격, 별점, 태그된 게시물)
                DrinkDetails(drink: drink, usedTo: usedTo)
                CustomDivider()
                // 단맛 / 신맛 / 청량 / 바디 / 탄산  or  향 / 맛 / 여운
                switch drink.category {
                case DrinkType.traditional.rawValue:
                    // 단맛 / 신맛 / 청량 / 바디 / 탄산
                    KoreanTastingNotes(sweet: drink.sweet, sour: drink.sour, refresh: drink.refresh,
                                       bodyFeel: drink.body, carbonated: drink.carbonated)
                    CustomDivider()
                    // 재료
                    DrinkMaterial(material: drink.material, windowWidth: windowWidth)
                default:
                    // 향 / 맛 / 여운
                    TastingNotes(aroma: drink.aroma, taste: drink.taste, finish: drink.finish)
                }
                CustomDivider()
                // 잘어울리는 음식
                WellMatched(wellMatched: drink.wellMatched,
                            windowWidth: windowWidth,
                            drinkName: drink.name,
                            drinkCategory: drink.category)
                CustomDivider()
                // 차트 - 선호하는 연령, 성별 ( 데이터 있을 때만 보여주기 )
                if drink.agePreference.values.reduce(0, +) > 0,
                   drink.genderPreference.values.reduce(0, +) > 0 {
                    PeferenceChart(ageGroupPieData:
                                    drinkViewModel.getPieModelData(ageData: drink.agePreference),
                                   genderGroupPieData:
                                    drinkViewModel.getPieModelData(genderData: drink.genderPreference))
                    CustomDivider()
                }
                // 태그된 인기 게시물
                if drink.taggedPostID.count > 0 {
                    TaggedTrendingPosts(drink: drink)
                }
            }
        }
        .task {
            windowWidth = TagHandler.getScreenWidthWithoutPadding(padding: 20)
            // shareLink 용 이미지 가져오기
            if let uiImage = await drinkViewModel.getUIImage(
                                category: DrinkType(rawValue: drink.category) ?? .all,
                                detailedCategory: drink.type) {
                shareImage = Image(uiImage: uiImage)
            }
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    navigationRouter.back()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                // 공유하기
                ShareLink(item: drink.name,
                          subject: Text("이 링크를 확인해보세요."),
                          message: Text("주다 - JUDA 에서 술 정보를 공유했어요!"),
                          // 미리보기
                          preview: SharePreview(
                            Text(drink.name + " " + drink.amount),
                            image: shareImage)
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .tint(.mainBlack)
    }
}

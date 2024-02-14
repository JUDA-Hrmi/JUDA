//
//  DrinkDetailView.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// MARK: - 술 디테일 화면
struct DrinkDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var windowWidth: CGFloat = 0
    let drink: Drink
    
    var body: some View {
        // 세로 스크롤
        ScrollView {
            VStack(spacing: 10) {
                // 술 정보 (이미지, 이름, 나라, 도수, 가격, 별점, 태그된 게시물)
                DrinkDetails(drink: drink)
                CustomDivider()
                // 단맛 / 신맛 / 청량 / 바디 / 탄산  or  향 / 맛 / 여운
                switch drink.drinkType {
                case .korean:
                    if let drink = drink as? Korean {
                        // 단맛 / 신맛 / 청량 / 바디 / 탄산
                        KoreanTastingNotes(sweet: drink.sweet, sour: drink.sour, refresh: drink.refresh,
                                           bodyFeel: drink.body, carbonated: drink.carbonated)
                        CustomDivider()
                        // 재료
                        DrinkMaterial(material: drink.material, windowWidth: windowWidth)
                    }
                default:
                    // 향 / 맛 / 여운
                    if let drink = drink as? Wine {
                        TastingNotes(aroma: drink.aroma, taste: drink.taste, finish: drink.finish)
                    } else if let drink = drink as? Whiskey {
                        TastingNotes(aroma: drink.aroma, taste: drink.taste, finish: drink.finish)
                    } else if let drink = drink as? Beer {
                        TastingNotes(aroma: drink.aroma, taste: drink.taste, finish: drink.finish)
                    } else {
                        EmptyView()
                    }
                }
                CustomDivider()
                // 잘어울리는 음식
                WellMatched()
                CustomDivider()
                // 차트 - 선호하는 연령, 성별
                PeferenceChart()
                CustomDivider()
                // 태그된 인기 게시물
                TaggedTrendingPosts()
            }
        }
        .task {
            windowWidth = TagHandler.getScreenWidthWithoutPadding(padding: 20)
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                // 공유하기
                ShareLink(item: "Test", // TODO: 실제 공유하려는 내용으로 변경 필요
                          subject: Text("이 링크를 확인해보세요."),
                          message: Text("Hrmi 앱에서 술 정보를 공유했어요!"),
                          // 미리보기
                          preview: SharePreview(
                            Text("카누카 칵테일 700ml"), // TODO: 해당 술 이름으로 변경
                            image: Image("canuca")) // TODO: 해당 술의 이미지로 변경
                ) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .tint(.mainBlack)
    }
}

#Preview {
    DrinkDetailView(drink: Beer.beerSample02)
}

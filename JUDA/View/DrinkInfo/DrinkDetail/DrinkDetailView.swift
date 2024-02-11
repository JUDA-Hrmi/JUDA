//
//  DrinkDetailView.swift
//  JUDA
//
//  Created by phang on 1/30/24.
//

import SwiftUI

// UITest - Drink Dummy Data
struct DrinkDummyData: Identifiable {
    let id = UUID()
    let image: String
    let name: String
    let origin: String
    let abv: Double
    let price: String
    let rating: Double
    let tastingNotesList = ["Aroma", "Taste", "Finish"]
    let tastingNotes: [String: [String]]
    let wellMatchedFoods: [String]

    static let sample = DrinkDummyData(
        image: "canuca", name: "카누카 칵테일 700ml", origin: "스페인",
        abv: 15, price: "35,000원", rating: 4.7, tastingNotes: ["Aroma": ["달콤한", "라임"],
                                                                    "Taste": ["라임 모히또"],
                                                                    "Finish": ["상큼한", "쌉쌀한"]],
        wellMatchedFoods: ["피자", "타코", "갈릭 쉬림프"]
    )
}

// MARK: - 술 디테일 화면
struct DrinkDetailView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        // 세로 스크롤
        ScrollView {
            VStack(spacing: 10) {
                // 술 정보 (이미지, 이름, 나라, 도수, 가격, 별점, 태그된 게시물)
                DrinkDetails()
                CustomDivider()
                // 맛 + 향
                TastingNotes()
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
    DrinkDetailView()
}

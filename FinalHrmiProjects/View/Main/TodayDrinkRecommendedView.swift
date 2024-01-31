//
//  TodayDrinkRecommendedView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/31/24.
//

import SwiftUI

// MARK: - 오늘의 추천 술 데이터
struct TodayDrink: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let image: String
}

let TodayDrinkData: [TodayDrink] = [
    TodayDrink(title: "지평 막걸리", image:"jipyeong"),
    TodayDrink(title: "루나가이아 지비뽀", image:"jibibbo"),
    TodayDrink(title: "진로", image:"jinro"),
]

// MARK: - 오늘의 추천 술 뷰
struct TodayDrinkRecommendedView: View {
    let todayDrink: [TodayDrink] = TodayDrinkData
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ForEach(todayDrink, id: \.self) { sul in
                    TodayDrinkRecommendedCell(todayDrink: sul)
                }
            }
        }
    }
}

#Preview {
    TodayDrinkRecommendedView()
}

// MARK: - 오늘의 추천 술 뷰셀
struct TodayDrinkRecommendedCell: View {
    let todayDrink: TodayDrink
    var body: some View {
        VStack {
            Image(todayDrink.image)
                .padding()
            
            Text(todayDrink.title)
                .font(.regular12)
                .multilineTextAlignment(.center)
                .lineLimit(2)               ///술 이름은 2줄이 최대로?
        }
        .padding(20)
    }
}

#Preview {
    TodayDrinkRecommendedCell(todayDrink: TodayDrink(title: "지평 막걸리", image:"jipyeong"))
}

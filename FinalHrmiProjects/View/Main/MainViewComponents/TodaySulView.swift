//
//  TodaySulView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/29/24.
//

import SwiftUI

// MARK: - 오늘의 추천 술 데이터
struct Todaydrink: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var image: String
}

var TodaysulData: [Todaydrink] = [
    Todaydrink(title: "지평 막걸리", image:"jipyeong"),
    Todaydrink(title: "루나가이아 지비뽀", image:"jibibbo"),
    Todaydrink(title: "진로", image:"jinro"),
]

// MARK: - 오늘의 추천 술 뷰
struct TodayDrinkView: View {
    var todaySul: [Todaydrink] = TodaysulData
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ForEach(todaySul, id: \.self) { sul in
                    TodayDrinkCell(todaySul: sul)
                }
            }
        }
    }
}

#Preview {
    TodayDrinkView()
}

// MARK: - 오늘의 추천 술 뷰셀
struct TodayDrinkCell: View {
    var todaySul: Todaydrink
    var body: some View {
        VStack {
            Image(todaySul.image)
                .padding()
            
            Text(todaySul.title)
                .font(.regular12)
                .multilineTextAlignment(.center)
                .lineLimit(2)               ///술 이름은 2줄이 최대로?
        }
        .padding(20)
    }
}

#Preview {
    TodayDrinkCell(todaySul: Todaydrink(title: "지평 막걸리", image:"jipyeong"))
}



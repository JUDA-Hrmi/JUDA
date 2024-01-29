//
//  TodaySulView.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/29/24.
//

import SwiftUI
import Foundation

// MARK: - 오늘의 추천 술 데이터
struct Todaysul: Identifiable,Hashable {
    var id = UUID()
    var title: String
    var image: String
}

var TodaysulData: [Todaysul] = [
    Todaysul(title: "지평 막걸리", image:"jipyeong"),
    Todaysul(title: "루나가이아 지비뽀", image:"jibibbo"),
    Todaysul(title: "진로", image:"jinro"),
]

// MARK: - 오늘의 추천 술 뷰
struct TodaysulView: View {
    var todaySul: [Todaysul] = TodaysulData
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                ForEach(todaySul, id: \.self) { sul in
                    TodaysulCell(todaySul: sul)
                }
            }
        }
    }
}

#Preview {
    TodaysulView()
}

// MARK: - 오늘의 추천 술 뷰셀
struct TodaysulCell: View {
    var todaySul: Todaysul
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
    TodaysulCell(todaySul: Todaysul(title: "지평 막걸리", image:"jipyeong"))
}



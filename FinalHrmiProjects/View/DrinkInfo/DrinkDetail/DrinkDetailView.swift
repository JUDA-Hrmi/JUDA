//
//  DrinkDetailView.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

// UITest - Drink Dummy Data
// TODO: 데이터 들어오면 ObservableObject 로 만들어질 데이터로 예상
struct DrinkDummyData: Identifiable {
    let id = UUID()
    let image: String
    let name: String
    let origin: String
    let abv: String
    let price: String
    let rating: String
    let tastingNotesList = ["Aroma", "Taste", "Finish"]
    let tastingNotes: [String: [String]]
    let wellMatchedFoods: [String]
    
    static let sample = DrinkDummyData(
        image: "canuca", name: "카누카 칵테일 700ml", origin: "스페인",
        abv: "15%", price: "35,000원", rating: "4.7", tastingNotes: ["Aroma": ["달콤한", "라임"],
                                                                    "Taste": ["라임 모히또"],
                                                                    "Finish": ["상큼한", "쌉쌀한"]],
        wellMatchedFoods: ["피자", "타코", "갈릭 쉬림프"]
    )
}

struct DrinkDetailView: View {
    var body: some View {
        // 세로 스크롤
        ScrollView {
            VStack(spacing: 0) {
                // 술 정보 (이미지, 이름, 나라, 도수, 가격, 별점, 태그된 게시물)
                DrinkDetails()
            }
        }
    }
}

#Preview {
    DrinkDetailView()
}

//
//  LikedDrinkList.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

struct LikedDrinkList: View {
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(0..<10, id: \.self) { _ in
                    // TODO: 추후에 네비게이션으로 해당 술의 Detail 로 이동 연결
                    DrinkListCell()
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    LikedDrinkList()
}

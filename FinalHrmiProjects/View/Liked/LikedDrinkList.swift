//
//  LikedDrinkList.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/26/24.
//

import SwiftUI

struct LikedDrinkList: View {
    @State private var scrollAxis: Axis.Set = .vertical
    @State private var vHeight = 0.0
    
    var body: some View {
        CustomScrollView(scrollAxis: $scrollAxis,
                         vHeight: $vHeight) {
            LazyVStack {
                ForEach(0..<10, id: \.self) { _ in
                    // TODO: 추후에 네비게이션으로 해당 술의 Detail 로 이동 연결
                    DrinkListCell()
                }
            }
        }
    }
}

#Preview {
    LikedDrinkList()
}

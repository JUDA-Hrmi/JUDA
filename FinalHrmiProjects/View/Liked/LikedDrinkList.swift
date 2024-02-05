//
//  LikedDrinkList.swift
//  FinalHrmiProjects
//
//  Created by phang on 1/31/24.
//

import SwiftUI

struct LikedDrinkList: View {

    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                LikedDrinkListContent()
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollIndicators(.hidden)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                LikedDrinkListContent()
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    LikedDrinkListContent()
                }
                .scrollIndicators(.hidden)
            }
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 술찜 리스트
struct LikedDrinkListContent: View {
    var body: some View {
        LazyVStack {
            ForEach(0..<3, id: \.self) { _ in
                // TODO: 추후에 네비게이션으로 해당 술의 Detail 로 이동 연결
                NavigationLink {
                    DrinkDetailView()
                        .modifier(TabBarHidden())
                } label: {
                    DrinkListCell()
                }
            }
        }
    }
}

#Preview {
    LikedDrinkList()
}

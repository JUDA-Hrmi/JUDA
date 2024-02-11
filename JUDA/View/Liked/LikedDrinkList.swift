//
//  LikedDrinkList.swift
//  JUDA
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// MARK: - 술찜 리스트 탭 화면
struct LikedDrinkList: View {
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                LikedDrinkListContent()
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                LikedDrinkListContent()
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    LikedDrinkListContent()
                }
            }
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 술찜 리스트
struct LikedDrinkListContent: View {
    var body: some View {
        LazyVStack {
            ForEach(0..<3, id: \.self) { _ in
                // TODO: NavigationLink - value 로 수정
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

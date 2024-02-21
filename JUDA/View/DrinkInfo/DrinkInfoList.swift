//
//  DrinkInfoList.swift
//  JUDA
//
//  Created by phang on 1/28/24.
//

import SwiftUI

// MARK: - 술장 리스트 뷰
struct DrinkInfoList: View {
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                DrinkListContent()
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollDismissesKeyboard(.immediately)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                DrinkListContent()
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    DrinkListContent()
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }
}

// MARK: - 술장 리스트 뷰 내용
struct DrinkListContent: View {
    @EnvironmentObject private var drinkViewModel: DrinkViewModel

    var body: some View {
        // 리스트
        LazyVStack {
            // TODO: 데이터 들어온 리스트로 ForEach
            ForEach(drinkViewModel.drinks.indices, id: \.self) { index in
                let drink = drinkViewModel.drinks[index]
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
                    DrinkDetailView(drink: drink)
                        .modifier(TabBarHidden())
                } label: {
//                    DrinkListCell(drink: drink)
                }
                .buttonStyle(EmptyActionStyle())
            }
        }
    }
}

#Preview {
    DrinkInfoList()
}

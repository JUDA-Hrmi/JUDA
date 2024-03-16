//
//  DrinkInfoList.swift
//  JUDA
//
//  Created by phang on 1/28/24.
//

import SwiftUI

// MARK: - 술장 리스트 뷰
struct DrinkInfoList: View {
    var searchDrinks = [Drink]()
    // DrinkInfo 에서 검색 중인지
    var searchInDrinkInfo: Bool = false
    
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                DrinkListContent(searchDrinks: searchDrinks,
                                 searchInDrinkInfo: searchInDrinkInfo)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollDismissesKeyboard(.immediately)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                DrinkListContent(searchDrinks: searchDrinks,
                                 searchInDrinkInfo: searchInDrinkInfo)
                .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    DrinkListContent(searchDrinks: searchDrinks,
                                     searchInDrinkInfo: searchInDrinkInfo)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }
}

// MARK: - 술장 리스트 뷰 내용
struct DrinkListContent: View {
    @EnvironmentObject private var drinkViewModel: DrinkViewModel

    var searchDrinks = [Drink]()
    // DrinkInfo 에서 검색 중인지
    var searchInDrinkInfo: Bool = false

    var body: some View {
        // 리스트
        LazyVStack {
            // DrinkInfo 에서 검색 중일때
            if searchInDrinkInfo {
                ForEach(searchDrinks, id: \.drinkField.drinkID) { drink in
                    NavigationLink(value: Route
                        .DrinkDetail(drink: drink)) {
							DrinkListCell(drink: drink)
                    }
                    .buttonStyle(EmptyActionStyle())
                }
            // 검색 안할때, 평상시 View
            } else {
                if !drinkViewModel.isLoading {
                    ForEach(drinkViewModel.drinks, id: \.drinkField.drinkID) { drink in
                        NavigationLink(value: Route
                            .DrinkDetail(drink: drink)) {
                            DrinkListCell(drink: drink)
                            .task {
                                if drink == drinkViewModel.drinks.last {
                                    await drinkViewModel.loadDrinksNextPage()
                                }
                            }
                        }
                        .buttonStyle(EmptyActionStyle())
                    }
                } else {
                    ForEach(0..<10) { _ in
                        ShimmerDrinkListCell()
                    }
                }
            }
        }
    }
}

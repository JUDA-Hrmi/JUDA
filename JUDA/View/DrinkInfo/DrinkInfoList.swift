//
//  DrinkInfoList.swift
//  JUDA
//
//  Created by phang on 1/28/24.
//

import SwiftUI

// MARK: - 술장 리스트 뷰
struct DrinkInfoList: View {
    // DrinkInfo 에서 검색 중인지
    var searchInDrinkInfo: Bool = false
    
    var body: some View {
        // MARK: iOS 16.4 이상
        if #available(iOS 16.4, *) {
            ScrollView() {
                DrinkListContent(searchInDrinkInfo: searchInDrinkInfo)
            }
            .scrollBounceBehavior(.basedOnSize, axes: .vertical)
            .scrollDismissesKeyboard(.immediately)
        // MARK: iOS 16.4 미만
        } else {
            ViewThatFits(in: .vertical) {
                DrinkListContent(searchInDrinkInfo: searchInDrinkInfo)
                    .frame(maxHeight: .infinity, alignment: .top)
                ScrollView {
                    DrinkListContent(searchInDrinkInfo: searchInDrinkInfo)
                }
                .scrollDismissesKeyboard(.immediately)
            }
        }
    }
}

// MARK: - 술장 리스트 뷰 내용
struct DrinkListContent: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var drinkViewModel: DrinkViewModel
    @EnvironmentObject private var searchDrinkViewModel: SearchDrinkViewModel

    // DrinkInfo 에서 검색 중인지
    var searchInDrinkInfo: Bool = false

    var body: some View {
        // 리스트
        LazyVStack {
            // DrinkInfo 에서 검색 중일때
            if searchInDrinkInfo {
                ForEach(searchDrinkViewModel.searchDrinks.indices, id: \.self) { index in
                    let drink = searchDrinkViewModel.searchDrinks[index]
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        DrinkDetailView(drink: drink)
                            .modifier(TabBarHidden())
                    } label: {
                        DrinkListCell(drink: drink,
                                      isLiked: authService.likedDrinks.contains{ $0 == drink.drinkID })
                    }
                    .buttonStyle(EmptyActionStyle())
                }
            // 검색 안할때, 평상시 View
            } else {
                if !drinkViewModel.isLoading {
                    ForEach(drinkViewModel.drinks, id: \.drinkID) { drink in
                        // TODO: NavigationLink - value 로 수정
                        NavigationLink {
                            DrinkDetailView(drink: drink)
                                .modifier(TabBarHidden())
                        } label: {
                            DrinkListCell(drink: drink,
                                          isLiked: authService.likedDrinks.contains{ $0 == drink.drinkID })
                                .task {
                                    if drink.name == drinkViewModel.drinks.last?.name {
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

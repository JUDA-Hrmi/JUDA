//
//  LikedDrinkList.swift
//  JUDA
//
//  Created by phang on 1/31/24.
//

import SwiftUI

// MARK: - 술찜 리스트 탭 화면
struct LikedDrinkList: View {
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        if !authService.likedDrinks.isEmpty {
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
        } else {
            Text("좋아하는 술이 없어요!")
                .font(.medium16)
                .foregroundStyle(.mainBlack)
        }
    }
}

// MARK: - 스크롤 뷰 or 뷰 로 보여질 술찜 리스트
struct LikedDrinkListContent: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var likedViewModel: LikedViewModel
    
    var body: some View {
        LazyVStack {
            if !likedViewModel.isLoading {
                ForEach(likedViewModel.likedDrinks.indices, id: \.self) { index in
                    let drink = likedViewModel.likedDrinks[index]
                    // TODO: NavigationLink - value 로 수정
                    NavigationLink {
                        DrinkDetailView(drink: drink)
                            .modifier(TabBarHidden())
                    } label: {
                        DrinkListCell(drink: drink,
                                      isLiked: true,
                                      liked: true)
                    }
                    .buttonStyle(EmptyActionStyle())
                }
            } else {
                ForEach(0..<4) { _ in
                    ShimmerDrinkListCell()
                }
            }
        }
        .task {
            await likedViewModel
                .getLikedDrinks(likedDrinksIDList: authService.likedDrinks)
        }
    }
}

#Preview {
    LikedDrinkList()
}

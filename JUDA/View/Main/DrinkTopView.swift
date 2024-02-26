//
//  DrinkTopView.swift
//  JUDA
//
//  Created by 백대홍 on 2/25/24.
//

import SwiftUI

struct DrinkTopView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    @Binding var selectedTabIndex: Int
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("인기 술")
                    .font(.semibold20)
                
                Spacer()
                
                Button {
                    selectedTabIndex = 1
                } label: {
                    Text("더보기")
                        .foregroundStyle(.gray01)
                        .font(.semibold16)
                }
            }
            .padding(20)
            
            ForEach(mainViewModel.drinks, id:\.drinkID) { drink in
                // TODO: NavigationLink - value 로 수정
                NavigationLink {
                    DrinkDetailView(drink: drink, usedTo: .main)
                        .modifier(TabBarHidden())
                } label: {
                    DrinkListCell(drink: drink,
                                  isLiked: authService.likedDrinks.contains{ $0 == drink.drinkID },
                                  usedTo: .main)
                }
            }
        }
    }
}


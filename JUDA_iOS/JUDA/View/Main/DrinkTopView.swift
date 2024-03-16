//
//  DrinkTopView.swift
//  JUDA
//
//  Created by 백대홍 on 2/25/24.
//

import SwiftUI

struct DrinkTopView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var mainViewModel: MainViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .lastTextBaseline) {
                Text("인기 술")
                    .font(.semibold20)
                
                Spacer()
                
                Button {
					appViewModel.selectedTabIndex = 1
                } label: {
                    Text("더보기")
                        .foregroundStyle(.gray01)
                        .font(.semibold16)
                }
            }
            .padding(20)
            
            ForEach(mainViewModel.drinks, id:\.drinkField.drinkID) { drink in
                NavigationLink(value: Route
                    .DrinkDetailWithUsedTo(drink: drink,
                                           usedTo: .main)) {
                    DrinkListCell(drink: drink,
                                  usedTo: .main)
                }
            }
        }
    }
}


//
//  MainView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    @State private var isLoggedIn = true
	@Binding var selectedTabIndex: Int
	
    var body: some View {
        NavigationStack {
            VStack(alignment: .center) {
                Spacer()

                WeatherAndFood(isLoggedIn: $isLoggedIn)
                Spacer()
                
                SuggestDrink(isLoggedIn: $isLoggedIn)
                Spacer()
                
                PostOrLogin(isLoggedIn: $isLoggedIn, selectedTabIndex: $selectedTabIndex)
                Spacer()
            }
            .padding(.horizontal, 20)
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

#Preview {
	MainView(selectedTabIndex: .constant(0))
}

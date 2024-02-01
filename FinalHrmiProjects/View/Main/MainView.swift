//
//  MainView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct MainView: View {
    @State private var isLoggedIn = true
	@Binding var selectedTabIndex: Int
	
    var body: some View {
		VStack(alignment: .center) {
			VStack(alignment: .center, spacing: 20) {
				WeatherView(isLoggedIn: $isLoggedIn)
					.padding(.bottom, 20)
			}
			SuggestDrinkView(isLoggedIn: $isLoggedIn, selectedTabIndex: $selectedTabIndex)
		}
        .padding(.horizontal, 20)
    }
}

#Preview {
	MainView(selectedTabIndex: .constant(0))
}

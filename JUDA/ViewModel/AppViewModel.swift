//
//  AppViewModel.swift
//  JUDA
//
//  Created by phang on 2/5/24.
//

import SwiftUI

final class AppViewModel: ObservableObject {
    @Published var tabBarState: Visibility = .visible
}

// MARK: - 탭 바 숨기는 Modifier
struct TabBarHidden: ViewModifier {
    @EnvironmentObject private var appViewModel: AppViewModel

    func body(content: Content) -> some View {
        content
            .onAppear {
                appViewModel.tabBarState = .hidden
            }
            .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

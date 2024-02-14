//
//  AppViewModel.swift
//  JUDA
//
//  Created by phang on 2/5/24.
//

import SwiftUI

// MARK: - 앱 전체에서 사용
final class AppViewModel: ObservableObject {
    // 탭바 상태
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

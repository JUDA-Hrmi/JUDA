//
//  ContentView.swift
//  JUDA
//
//  Created by 정인선 on 1/26/24.
//

import SwiftUI

// MARK: - 앱 전체 스타트 탭 뷰
struct ContentView: View {
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject var colorScheme: SystemColorTheme

    @StateObject private var locationManager = LocationManager()
    @StateObject private var aiViewModel = AiViewModel()
    @StateObject private var drinkViewModel = DrinkViewModel()
    @StateObject private var recordViewModel = RecordViewModel()
    @StateObject private var postsViewModel = PostsViewModel()
    @StateObject private var likedViewModel = LikedViewModel()
    @StateObject private var notificationViewModel = AlarmViewModel()

    // 현재 선택된 탭의 인덱스. 초기값 0
    @State private var selectedTabIndex = 0

    // Tabbar 불투명하게 설정 (색상 백그라운드)
    init() {
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
        UITabBar.appearance().isTranslucent = true
        UITabBar.appearance().backgroundColor = .systemBackground
    }
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            ForEach(0..<TabItem.tabItems.count, id: \.self) { index in
                let item = TabItem.tabItems[index]
                tabItemView(viewType: item.viewType)
                    .tabItem {
                        // symbolType에 따라 Image 파라미터 다르게 생성
                        switch item.symbolType {
                            // 커스텀된 symbol일 때, Image(_: String) 사용
                        case .customSymbol:
                            Image(item.symbolName)
                            // 탭 선택 시, symbol fill로 변경되게 환경 변수 변경
                                .environment(\.symbolVariants, selectedTabIndex == index ? .fill : .none)
                            // sf symbol 사용할 때, Image(systemName: String) 사용
                        case .sfSymbol:
                            Image(systemName: item.symbolName)
                                .environment(\.symbolVariants, selectedTabIndex == index ? .fill : .none)
                        }
                        Text(item.name)
                            .font(.medium10)
                    }
                    .tag(index)
            }
        }
        // deepLink 통해서, url 의 host 에 따라 탭 이동.
        .onOpenURL { url in
            guard let tabID = url.tabIdentifier else { return }
            switch tabID {
            case .drinks:
                selectedTabIndex = 1
            case .posts:
                selectedTabIndex = 2
            }
        }
        .tint(.mainAccent03)
        // SettingView - 화면 모드 -> 선택한 옵션에 따라 배경색 변환
        .preferredColorScheme(colorScheme.selectedColor == .light ? .light : colorScheme.selectedColor == .dark ? .dark : .none)
    }
    
    // viewType에 따라 특정 View를 리턴해주는 함수
    @ViewBuilder
    private func tabItemView(viewType: ViewType) -> some View {
        switch viewType {
        case .main:
            MainView(selectedTabIndex: $selectedTabIndex)
                .environmentObject(locationManager)
                .environmentObject(aiViewModel)
//                .environmentObject(aiTodayViewModel)
        case .drinkInfo:
            DrinkInfoView()
                .environmentObject(drinkViewModel)
        case .posts:
            PostsView()
                .environmentObject(recordViewModel)
				.environmentObject(postsViewModel)
        case .liked:
            if authService.signInStatus {
                LikedView()
                    .environmentObject(recordViewModel)
                    .environmentObject(drinkViewModel)
                    .environmentObject(likedViewModel)
            } else {
                EmptyView()
            }
        case .myPage:
            if authService.signInStatus {
                MypageView(selectedTabIndex: $selectedTabIndex)
                    .environmentObject(notificationViewModel)
            } else {
                unauthenticatedMypageView(selectedTabIndex: $selectedTabIndex)
            }
        }
    }
}

#Preview {
    ContentView()
}

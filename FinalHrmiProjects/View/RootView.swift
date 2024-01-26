//
//  RootView.swift
//  FinalHrmiProjects
//
//  Created by 정인선 on 1/26/24.
//

import SwiftUI

// ForEach문 내부 Image를 파라미터에 따라 처리해주기 위해 생성
enum SymbolType {
    case sfSymbol, customSymbol
}

// ForEach문 내부 View 변경을 위해 생성
enum ViewType {
    case main, drinkInfo, posts, liked, myPage
}

// TabItem에 필요한 데이터
struct TabItem {
    let name: String
    let symbolName: String
    let symbolType: SymbolType
    let viewType: ViewType
    
    static let tabItems = [
        TabItem(name: "홈", symbolName: "house", symbolType: .sfSymbol, viewType: .main),
        TabItem(name: "술장", symbolName: "wineglass", symbolType: .sfSymbol, viewType: .drinkInfo),
        TabItem(name: "술상", symbolName: "square.grid", symbolType: .customSymbol, viewType: .posts),
        TabItem(name: "술찜", symbolName: "heart", symbolType: .sfSymbol, viewType: .liked),
        TabItem(name: "마이페이지", symbolName: "person", symbolType: .sfSymbol, viewType: .myPage)
    ]
}

struct RootView: View {
    // 현재 선택된 탭의 인덱스. 초기값 0
    @State private var selectedTabIndex = 0
    
    var body: some View {
        TabView(selection: $selectedTabIndex) {
            ForEach(0..<5) { index in
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
        .tint(.mainAccent03)
    }
    
    // viewType에 따라 특정 View를 리턴해주는 함수
    @ViewBuilder
    private func tabItemView(viewType: ViewType) -> some View {
        switch viewType {
        case .main:
            MainView()
        case .drinkInfo:
            DrinkInfoView()
        case .posts:
            PostsView()
        case .liked:
            LikedView()
        case .myPage:
            MypageView()
        }
    }
}

#Preview {
    RootView()
}

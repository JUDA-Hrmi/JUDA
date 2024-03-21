//
//  TabItems.swift
//  JUDA
//
//  Created by 정인선 on 1/29/24.
//

import Foundation

// MARK: - 앱 최상단 탭뷰의 TabItem 에 필요한 데이터 모델
struct TabItem: Identifiable {
    let id = UUID()
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

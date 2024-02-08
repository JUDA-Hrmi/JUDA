//
//  TabItems.swift
//  JUDA
//
//  Created by 정인선 on 1/29/24.
//

import Foundation

// RootView ForEach문 내부 Image를 파라미터에 따라 처리해주기 위해 생성
enum SymbolType {
    case sfSymbol, customSymbol
}

// RootView ForEach문 내부 View 변경을 위해 생성
enum ViewType {
    case main, drinkInfo, posts, liked, myPage
}

// TabItem에 필요한 데이터
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

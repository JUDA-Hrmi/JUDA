//
//  URL +.swift
//  JUDA
//
//  Created by phang on 2/24/24.
//

import Foundation

// MARK: - URL + (딥링크)
extension URL {
    // info 에서 설정한 주소 맞는지
    var isDeepLink: Bool {
        return scheme == "juda-app"
    }
    
    // url -> 무슨 탭 보여줄지
    var tabIdentifier: TabIdentifier? {
        guard isDeepLink else { return nil }
        switch host {
        case TabIdentifier.posts.rawValue:
            return .posts
        case TabIdentifier.drinks.rawValue:
            return .drinks
        default:
            return nil
        }
    }
    
    var detailPage: PageIdentifier? {
        guard let tabID = tabIdentifier,
              pathComponents.count > 1 else { return nil }
        let idString = pathComponents[1]
        switch tabID {
        case .posts:
            return .postItem(id: idString)
        case .drinks:
            return .drinkItem(id: idString)
        }
    }
}


// MARK: - 어느 탭 보여줄지 enum
enum TabIdentifier: String, Hashable {
    case posts, drinks
}

// MARK: - 어느 뷰? 보여줄지 enum
enum PageIdentifier: Hashable {
    case drinkItem(id: String)
    case postItem(id: String)
}

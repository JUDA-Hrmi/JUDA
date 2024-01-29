//
//  View +.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/25.
//

import SwiftUI

extension View {
  func hideKeyboard() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
  }
}


// MARK: - CustomNavigation View

extension View {
    
    // 뷰가 사라질 때 실행할 클로저를 받아 "onWillDisappear" 모디파이어를 추가하는 메서드
    func onWillDisappear(_ perform: @escaping () -> Void) -> some View {
        self.modifier(WillDisappearModifier(callback: perform))
    }
    
    // 사용자 지정 네비게이션 바를 처리하는 커스텀 네비게이션바 Modifier
    func customNavigationBar<C, L, T> (
        centerView: @escaping (() -> C) = { EmptyView() },
        leadingView: @escaping (() -> L),
        trailingView: [NavigationTrailingButtonPostion: () -> T] = [:]
    ) -> some View where C: View, L: View, T: View {
        modifier(
            CustomNavigationBarModifier(
                centerView: centerView,
                leadingView: leadingView,
                trailingViews: trailingView
            )
        )
    }
}

//
//  CustomLoadingView.swift
//  JUDA
//
//  Created by phang on 2/19/24.
//

import SwiftUI

// MARK: - 화면에 윈도우로 덮어서 띄울 로딩 뷰
struct CustomLoadingView: View {
    var body: some View {
        VStack {
            LottieView(jsonName: "DrinkLoading")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.mainBlack.opacity(0.1))
    }
}

// MARK: - CustomLoadingView 모디파이어
struct CustomLoadingViewModifier: ViewModifier {
    @Binding var isLoading: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isLoading {
                CustomLoadingView()
                    // 기존 뷰 (content) 위에 표시
                    .zIndex(1)
            }
        }
    }
}

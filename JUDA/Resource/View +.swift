//
//  View +.swift
//  JUDA
//
//  Created by phang on 2/19/24.
//

import SwiftUI

// MARK: - View +
extension View {
    // 로딩뷰 사용 간편화를 위함
    func loadingView(_ isLoading: Binding<Bool>) -> some View {
        return self.modifier(CustomLoadingViewModifier(isLoading: isLoading))
    }
}

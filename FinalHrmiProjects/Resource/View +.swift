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



// MARK: - 새로운 키보드 숨기기 코드

extension UIApplication {   // 탭 제스처를 추가하는 메서드
    
    func addTapGestureRecognizer() {
        // 앱의 첫 번째 창을 가져옴
        guard let window = windows.first else { return }
        // 탭 제스처 생성
        let tapGesture = UITapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        // 탭 제스처가 동시에 발생하는 다른 제스처와 충돌하지 않도록 설정
        tapGesture.requiresExclusiveTouchType = false
        // 탭 제스처가 다른 뷰에 의해 취소되지 않도록 설정
        tapGesture.cancelsTouchesInView = false
        // 탭 제스처의 델리게이트를 현재 UIApplication으로 설정
        tapGesture.delegate = self
        // 창에 탭 제스처 추가
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    // 다른 제스처와 함께 탭을 동시에 인식할지 여부를 결정하는 메서드
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
        
        // true 반환: 다른 제스처와 함께 탭을 동시에 인식함
        // false 반환: 다른 제스처 동작 중에는 탭을 인식하지 않음
    }
}

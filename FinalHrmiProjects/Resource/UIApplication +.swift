//
//  UIApplication +.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/25.
//

import SwiftUI

// MARK: - 새로운 키보드 숨기기 코드

extension UIApplication {   // 탭 제스처를 추가하는 메서드
    
    func addTapGestureRecognizer() {
		let scenes = UIApplication.shared.connectedScenes
		let windowScene = scenes.first as? UIWindowScene
		// 앱의 첫 번째 창을 가져옴
		guard let window = windowScene?.windows.first else { return }
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

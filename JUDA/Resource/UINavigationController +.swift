//
//  UINavigationController +.swift
//  JUDA
//
//  Created by phang on 2/8/24.
//

import SwiftUI

// MARK: - 스와이프 뒤로가기 제스처
extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}

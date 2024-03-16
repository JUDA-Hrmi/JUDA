//
//  Debouncer.swift
//  JUDA
//
//  Created by phang on 2/23/24.
//

import Foundation

// MARK: - 연속된 입력 (텍필 or 버튼)에 의한 데이터베이스에 연속된 요청을 막기 위한 디바운서
class Debouncer {
    private let delay: TimeInterval
    private var callback: (() -> Void)?
    private var timer: Timer?

    init(delay: TimeInterval) {
        self.delay = delay
    }

    func call(callback: @escaping () -> Void) {
        self.callback = callback
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: delay,
                                     target: self,
                                     selector: #selector(fireCallback),
                                     userInfo: nil,
                                     repeats: false)
    }

    @objc private func fireCallback() {
        callback?()
        callback = nil
    }
}

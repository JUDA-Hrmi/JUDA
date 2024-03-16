//
//  Theme.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/28.
//

import SwiftUI

// MARK: - 화면 테마
struct Theme {
  static func backgroundColor(scheme: ColorScheme) -> Color {
    let lightColor = Color.white
    let darkColor = Color.gray06
    
    switch scheme {
    case .light:
      return lightColor
    case .dark:
      return darkColor
    @unknown default:
      return lightColor
    }
  }
}

enum JUDAColorScheme: String {
    case light = "light"
    case dark = "dark"
}

final class SystemColorTheme: ObservableObject {
    @Published var selectedColor: JUDAColorScheme? {
        // selectedColor가 변경될 때마다 해당 값을 UserDefaults에 저장
        // 사용자가 변경한 색상 테마가 유지, 다시 앱 실행할 때도 적용
        didSet {
            UserDefaults.standard.set(selectedColor?.rawValue, forKey: "selectedColor")
        }
    }

    // 사용자가 이전에 선택한 색상 -> UserDefaults를 통해 가져온다.
    // 다시 앱 실행할 때도 유지되도록 저장
    init() {
        if let storedColorName = UserDefaults.standard.string(forKey: "selectedColor"),
            let storedColor = JUDAColorScheme(rawValue: storedColorName.lowercased()) {
            selectedColor = storedColor
        }
    }
}

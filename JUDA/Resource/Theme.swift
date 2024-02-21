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
        didSet {
            UserDefaults.standard.set(selectedColor?.rawValue, forKey: "selectedColor")
        }
    }

    init() {
        if let storedColorName = UserDefaults.standard.string(forKey: "selectedColor"),
            let storedColor = JUDAColorScheme(rawValue: storedColorName.lowercased()) {
            selectedColor = storedColor
        }
    }
}

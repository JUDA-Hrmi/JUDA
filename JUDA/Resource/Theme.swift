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

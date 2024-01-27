//
//  Theme.swift
//  FinalHrmiProjects
//
//  Created by 백대홍 on 1/27/24.
//

import SwiftUI
// MARK: - 다크 + 라이트 모드 대응을 위한 Color scheme

struct Theme {
  static func backgroundColor(scheme: ColorScheme) -> Color {
    let lightColor = Color.white
    let darkColor = Color.black
    
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

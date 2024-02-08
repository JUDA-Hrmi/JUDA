//
//  Button.swift
//  JUDA
//
//  Created by Minjae Kim on 1/29/24.
//

import SwiftUI

// NavigationLink: without Button blinking animation
struct EmptyActionStyle: ButtonStyle {
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
	}
}

// Image Xmark button Image
struct XmarkOnGrayCircle: View {
    var body: some View {
        Image(systemName: "xmark.circle.fill")
            // 심볼 레이어별로 색상 지정할 수 있게 렌더링모드 .palette 설정
            // xmark 색상 gray06, circle 색상 gray01
            .symbolRenderingMode(.palette)
            .foregroundStyle(.gray06, .gray01.opacity(0.6))
    }
}


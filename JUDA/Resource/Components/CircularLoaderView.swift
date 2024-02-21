//
//  CircularLoaderView.swift
//  JUDA
//
//  Created by phang on 2/21/24.
//

import SwiftUI

// MARK: - 이미지 불러 올 때, 사용할 원형 로딩 뷰
struct CircularLoaderView: View {
    @State private var animate = false
    let gradient = LinearGradient(
        stops: [
            Gradient.Stop(color: .gray03, location: 0.1),
            Gradient.Stop(color: .gray03.opacity(0.8), location: 0.4),
            Gradient.Stop(color: .gray03.opacity(0.4), location: 0.8)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    let size: CGFloat
    
    var body: some View {
        Circle()
            .stroke(gradient, lineWidth: 8)
            .frame(width: size, height: size)
            .rotationEffect(Angle(degrees: animate ? 360 : 0))
            .animation(
                Animation.linear(duration: 3)
                    .repeatForever(autoreverses: false),
                value: animate
            )
            .onAppear {
                withAnimation {
                    animate.toggle()
                }
            }
    }
}

#Preview {
    CircularLoaderView(size: 40)
}

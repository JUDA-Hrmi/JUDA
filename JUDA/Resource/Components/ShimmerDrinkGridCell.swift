//
//  ShimmerDrinkGridCell.swift
//  JUDA
//
//  Created by phang on 2/25/24.
//

import SwiftUI

// MARK: - 로딩 중, 술 리스트 셀
struct ShimmerDrinkGridCell: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var show: Bool = false
    private var overColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    var body: some View {
        ZStack {
            // shimmer view
            VStack(alignment: .trailing, spacing: 10) {
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBlack.opacity(0.09))
                    .frame(width: 26, height: 26)
                // 술 정보
                VStack(alignment: .leading, spacing: 10) {
                    // 술 사진
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 70, height: 103.48)
                    }
                    .frame(maxWidth: .infinity)
                    // 술 이름 + 용량
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 130, height: 15)
                    // 나라, 지방
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 100, height: 15)
                    // 타입, 도수
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 100, height: 15)
                    Spacer()
                    // 별
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 80, height: 15)
                }
            }
            // shimmer animation view
            VStack(alignment: .trailing, spacing: 10) {
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .frame(width: 26, height: 26)
                // 술 정보
                VStack(alignment: .leading, spacing: 10) {
                    // 술 사진
                    VStack(alignment: .center) {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 70, height: 103.48)
                    }
                    .frame(maxWidth: .infinity)
                    // 술 이름 + 용량
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 130, height: 15)
                    // 나라, 지방
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 100, height: 15)
                    // 타입, 도수
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 100, height: 15)
                    Spacer()
                    // 별
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 80, height: 15)
                }
            }
            .mask {
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .rotationEffect(.init(degrees: 20))
                    .offset(x: show ? 800 : -150)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    show.toggle()
                }
            }
        }
        .frame(height: 270)
        .padding(10)
    }
}
#Preview {
    ShimmerDrinkGridCell()
}

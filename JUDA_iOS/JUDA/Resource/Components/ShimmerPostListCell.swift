//
//  ShimmerPostListCell.swift
//  JUDA
//
//  Created by phang on 2/26/24.
//

import SwiftUI

// MARK: - 로딩 중, 술상 리스트 셀
struct ShimmerPostListCell: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var show: Bool = false
    private var overColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    var body: some View {
        ZStack {
            // shimmer view
            HStack(alignment: .center, spacing: 20) {
                // Post 이미지
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBlack.opacity(0.09))
                    .frame(width: 70, height: 70)
                // 유저, 태그, 좋아요
                VStack(alignment: .leading, spacing: 6) {
                    // 유저
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 100, height: 16)
                    // 태그
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 40, height: 16)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 40, height: 16)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 40, height: 16)
                    }
                    // 좋아요
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 24, height: 16)
                }
            }
            // shimmer animation view
            HStack(alignment: .center, spacing: 20) {
                // Post 이미지
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .frame(width: 70, height: 70)
                // 유저, 태그, 좋아요
                VStack(alignment: .leading, spacing: 6) {
                    // 유저
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 100, height: 16)
                    // 태그
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.09))
                            .frame(width: 40, height: 16)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.09))
                            .frame(width: 40, height: 16)
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.09))
                            .frame(width: 40, height: 16)
                    }
                    // 좋아요
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 24, height: 16)
                }
            }
            .mask {
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .rotationEffect(.init(degrees: 120))
                    .offset(x: show ? 800 : -150)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    show.toggle()
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ShimmerPostListCell()
}

//
//  ShimmerPostCell.swift
//  JUDA
//
//  Created by phang on 2/25/24.
//

import SwiftUI

// MARK: - 로딩 중, 술 리스트 셀
struct ShimmerPostCell: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var show: Bool = false
    private var overColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    var body: some View {
        ZStack {
            // shimmer view
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    // 게시글 사진리스트의 첫 번째 사진
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(height: 170)
                }
                HStack {
                    HStack {
                        // 사용자의 프로필 사진
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 20, height: 20)
                        // 사용자의 닉네임
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 80, height: 15)
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    // 좋아요 버튼
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 26, height: 26)
                    }
                    .padding(.trailing, 5)
                }
                .frame(height: 35)
            }
            // shimmer animation view
            VStack(spacing: 0) {
                ZStack(alignment: .topTrailing) {
                    // 게시글 사진리스트의 첫 번째 사진
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(height: 170)
                }
                HStack {
                    HStack {
                        // 사용자의 프로필 사진
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 20, height: 20)
                        // 사용자의 닉네임
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 80, height: 15)
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    // 좋아요 버튼
                    HStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 26, height: 26)
                    }
                    .padding(.trailing, 5)
                }
                .frame(height: 35)
            }
            .mask {
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .rotationEffect(.init(degrees: 10))
                    .offset(x: show ? 800 : -150)
            }
            .onAppear {
                withAnimation(.linear(duration: 1.0).repeatForever(autoreverses: false)) {
                    show.toggle()
                }
            }
        }
        .frame(maxWidth: 170, maxHeight: 200)
    }
}

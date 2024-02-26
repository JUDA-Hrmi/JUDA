//
//  ShimmerDrinkListCell.swift
//  JUDA
//
//  Created by phang on 2/25/24.
//

import SwiftUI

// MARK: - 로딩 중, 술 리스트 셀
struct ShimmerDrinkListCell: View {
    @Environment(\.colorScheme) var colorScheme
    @State private var show: Bool = false
    private var overColor: Color {
        colorScheme == .light ? .white : .black
    }
    
    var body: some View {
        ZStack {
            // shimmer view
            HStack(alignment: .top) {
                // 술 정보
                HStack(alignment: .center, spacing: 20) {
                    // 술 사진
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.mainBlack.opacity(0.09))
                        .frame(width: 70, height: 103.48)
                    // 술 이름 + 나라, 도수 + 별점
                    VStack(alignment: .leading, spacing: 10) {
                        // 술 이름 + 용량
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 200, height: 15)
                        // 나라, 도수
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 150, height: 15)
                        // 별점
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.mainBlack.opacity(0.09))
                            .frame(width: 120, height: 15)
                    }
                }
                Spacer()
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(.mainBlack.opacity(0.09))
                    .frame(width: 26, height: 26)
            }
            // shimmer animation view
            HStack(alignment: .top) {
                // 술 정보
                HStack(alignment: .center, spacing: 20) {
                    // 술 사진
                    RoundedRectangle(cornerRadius: 10)
                        .fill(overColor.opacity(0.6))
                        .frame(width: 70, height: 103.48)
                    // 술 이름 + 나라, 도수 + 별점
                    VStack(alignment: .leading, spacing: 10) {
                        // 술 이름 + 용량
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 200, height: 15)
                        // 나라, 도수
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 150, height: 15)
                        // 별점
                        RoundedRectangle(cornerRadius: 10)
                            .fill(overColor.opacity(0.6))
                            .frame(width: 120, height: 15)
                    }
                }
                Spacer()
                // 하트
                RoundedRectangle(cornerRadius: 10)
                    .fill(overColor.opacity(0.6))
                    .frame(width: 26, height: 26)
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
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .frame(height: 130)
    }
}


#Preview {
    ShimmerDrinkListCell()
}

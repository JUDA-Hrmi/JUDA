//
//  StarRating.swift
//  JUDA
//
//  Created by 정인선 on 1/26/24.
//

import SwiftUI

// 평점 Text 추가 여부 확인용 enum type
enum StarRatingType {
    case none, withText
}

struct StarRating: View {
    // 평점
    let rating: Double
    // 별점 크기, 색상, 평점 텍스트 사이즈
    let color: Color
    let starSize: Font
    let fontSize: Font?
    let starRatingType: StarRatingType
    // full color로 채워지는 별의 개수
    private var fullStar: Int { Int(rating) }
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<5) { count in
                Image("star.filled")
                    .font(starSize)
                    .foregroundStyle(count < fullStar ? color : .gray04)
                    // 평점의 소수점이 0.5이상인 경우 회색 별에 반 개짜리 별을 오버레이
                    .overlay {
                        // 0.5 단위로 버림하여 보여줌
                        if count == fullStar && rating - Double(fullStar) >= 0.5 {
                            Image("star.half.filled")
                                .font(starSize)
                                .foregroundStyle(color)
                        }
                    }
            }
            if starRatingType == .withText {
                Text(Formatter.formattedStarRatingCount(rating: rating))
                    .font(fontSize)
                    .foregroundStyle(.mainBlack)
                    .padding(.leading, 10)
            }
        }
    }
}

#Preview {
//    StarRating(rating: 4.3, color: .mainAccent05, starSize: .regular14, fontSize: .regular14)
    
    StarRating(rating: 3.7, color: .mainAccent02, starSize: .regular18, fontSize: .regular18, starRatingType: .withText)
}

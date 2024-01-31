//
//  LikedView.swift
//  FinalHrmiProjects
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

struct LikedView: View {
    // UITest - 세그먼트 선택 index 저장
    @State private var selectedSegmentIndex = 0
    
    var body: some View {
        NavigationStack {
            // 세그먼트 (술찜 리스트 / 술상 리스트)
            CustomTextSegment(segments: PostOrLiked.liked, selectedSegmentIndex: $selectedSegmentIndex)
                .padding(.vertical, 14)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            // Likes
            PagerView(pageCount: PostOrLiked.liked.count, currentIndex: $selectedSegmentIndex) {
                ForEach(0..<PostOrLiked.liked.count, id: \.self) { idx in
                    ScrollViewReader { value in
                        Group {
                            if idx == 0 {
                                // 술찜 리스트
                                LikedDrinkList()
                            } else {
                                // 술상 리스트
                                LikedPostGrid()
                            }
                        }
                        .onChange(of: selectedSegmentIndex) { newValue in
                            value.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    LikedView()
}

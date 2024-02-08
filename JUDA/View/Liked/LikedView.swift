//
//  LikedView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// MARK: - 하트 누른 술 + 술상 볼 수 있는 탭
struct LikedView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    // UITest - 세그먼트 선택 index 저장
    @State private var selectedSegmentIndex = 0

    var body: some View {
        NavigationStack {
            VStack {
                // 세그먼트 (술찜 리스트 / 술상 리스트)
                CustomTextSegment(segments: PostOrLiked.liked, selectedSegmentIndex: $selectedSegmentIndex)
                    .padding(.vertical, 14)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 술찜 or 술상 탭 뷰
                TabView(selection: $selectedSegmentIndex) {
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
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

#Preview {
    LikedView()
}

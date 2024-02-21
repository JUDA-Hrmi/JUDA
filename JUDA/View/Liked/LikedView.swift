//
//  LikedView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI

// MARK: - 찜 세그먼트 enum
enum LikedType: String, CaseIterable {
    case drink = "술찜 리스트"
    case post = "술상 리스트"
}

// MARK: - 하트 누른 술 + 술상 볼 수 있는 탭
struct LikedView: View {
    @EnvironmentObject private var appViewModel: AppViewModel

    // UITest - 세그먼트 선택 index 저장
    @State private var selectedSegmentIndex = 0

    private let likedType = LikedType.allCases
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 세그먼트 (술찜 리스트 / 술상 리스트)
                CustomTextSegment(segments: likedType.map { $0.rawValue }, selectedSegmentIndex: $selectedSegmentIndex)
                    .padding(.bottom, 14)
                    .padding([.top, .horizontal], 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 술찜 or 술상 탭 뷰
                TabView(selection: $selectedSegmentIndex) {
                    ForEach(0..<likedType.count, id: \.self) { index in
                        ScrollViewReader { value in
                            Group {
                                if likedType[index] == .drink {
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

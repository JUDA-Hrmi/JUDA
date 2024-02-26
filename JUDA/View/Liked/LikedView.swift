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
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var likedViewModel: LikedViewModel

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
                                        .task {
                                            if likedViewModel.likedDrinks.isEmpty {
                                                await likedViewModel
                                                    .getLikedDrinks(likedDrinksIDList: authService.likedDrinks)
                                            }
                                        }
                                } else {
                                    // 술상 리스트
                                    LikedPostGrid()
                                        .task {
                                            if likedViewModel.likedPosts.isEmpty {
                                                await likedViewModel
                                                    .getLikedPosts(likedPostsIDList: authService.likedPosts)
                                            }
                                        }
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
            .onChange(of: selectedSegmentIndex) { newValue in
                Task {
                    // 술 -> 술상
                    if newValue == 1 {
                        await likedViewModel
                            .getLikedDrinks(likedDrinksIDList: authService.likedDrinks)
                        // 술상 -> 술
                    } else {
                        await likedViewModel
                            .getLikedPosts(likedPostsIDList: authService.likedPosts)
                    }
                }
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

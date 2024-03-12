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
    // 리스트
    static let list: [LikedType] = LikedType.allCases
}

// MARK: - 하트 누른 술 + 술상 볼 수 있는 탭
struct LikedView: View {
    @StateObject private var navigationRouter = NavigationRouter()
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var authService: AuthService
    @EnvironmentObject private var likedViewModel: LikedViewModel

    @State private var selectedSegmentIndex = 0
    
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            VStack(spacing: 0) {
                // 세그먼트 (술찜 리스트 / 술상 리스트)
                CustomTextSegment(segments: LikedType.list.map { $0.rawValue }, selectedSegmentIndex: $selectedSegmentIndex)
                    .padding(.bottom, 14)
                    .padding([.top, .horizontal], 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                // 술찜 or 술상 탭 뷰
                TabView(selection: $selectedSegmentIndex) {
                    ForEach(0..<LikedType.list.count, id: \.self) { index in
                        ScrollViewReader { value in
                            Group {
                                if LikedType.list[index] == .drink {
                                    // 술찜 리스트
                                    LikedDrinkList()
                                        .task {
                                            if likedViewModel.likedDrinks.isEmpty {
                                                await likedViewModel
                                                    .getLikedDrinks(likedDrinksIDList: authService.currentUser?.likedDrinks)
                                            }
                                        }
                                } else {
                                    // 술상 리스트
                                    LikedPostGrid()
                                        .task {
                                            if likedViewModel.likedPosts.isEmpty {
                                                await likedViewModel
                                                    .getLikedPosts(likedPostsIDList: authService.currentUser?.likedPosts)
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
            .navigationDestination(for: Route.self) { value in
                switch value {
                case .AddTag:
                    AddTagView()
                        .modifier(TabBarHidden())
                case .NavigationProfile(let postUserName,
                                      let postUserID,
                                      let usedTo):
                    NavigationProfileView(postUserName: postUserName,
                                          postUserID: postUserID,
                                          usedTo: usedTo)
                case .Record(let recordType):
                    RecordView(recordType: recordType)
                case .ChangeUserName:
                    ChangeUserNameView()
                        .modifier(TabBarHidden())
                //
                case .DrinkDetail(let drink):
                    DrinkDetailView(drink: drink)
                        .modifier(TabBarHidden())
                case .DrinkDetailWithUsedTo(let drink, let usedTo):
                    DrinkDetailView(drink: drink, usedTo: usedTo)
                        .modifier(TabBarHidden())
                //
                case .PostDetail(let postUserType,
                                 let post,
                                 let usedTo):
                    PostDetailView(postUserType: postUserType,
                                   post: post,
                                   usedTo: usedTo)
                    .modifier(TabBarHidden())

                default:
                    ErrorPageView()
                        .modifier(TabBarHidden())
                }
            }
            .onChange(of: selectedSegmentIndex) { newValue in
                Task {
                    // 술 -> 술상
                    if newValue == 1 {
                        await likedViewModel
                            .getLikedDrinks(likedDrinksIDList: authService.currentUser?.likedDrinks)
                        // 술상 -> 술
                    } else {
                        await likedViewModel
                            .getLikedPosts(likedPostsIDList: authService.currentUser?.likedPosts)
                    }
                }
            }
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .environmentObject(navigationRouter)
        .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

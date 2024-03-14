//
//  MainView.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import SwiftUI
import Lottie

// MARK: - 메인 탭
struct MainView: View {
    @StateObject private var navigationRouter = NavigationRouter()
    @EnvironmentObject private var appViewModel: AppViewModel
    @EnvironmentObject private var authViewModel: AuthViewModel
	
    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 날씨와 어울리는 술 + 안주
                    WeatherAndFood()
                    // 오늘의 술장 Top3
                    DrinkTopView()
                    // 오늘의 술상 Top3
                    PostTopView()
                }
                .padding(.bottom, 15)
            }
            .navigationDestination(for: Route.self) { value in
                switch value {
                case .ChangeUserName:
                    ChangeUserNameView()
                case .AddTag:
                    AddTagView()
                        .modifier(TabBarHidden())
                case .Login:
                    LogInView()
                        .modifier(TabBarHidden())
                case .NavigationPosts(let usedTo,
                                      let searchTagType,
                                      let taggedPosts,
                                      let selectedDrinkName,
                                      let selectedFoodTag):
                    NavigationPostsView(usedTo: usedTo,
                                        searchTagType: searchTagType,
                                        taggedPosts: taggedPosts,
                                        selectedDrinkName: selectedDrinkName,
                                        selectedFoodTag: selectedFoodTag)
                case .NavigationPostsTo(let usedTo,
                                        let searchTagType,
                                        let postSearchText):
                    NavigationPostsView(usedTo: usedTo,
                                        searchTagType: searchTagType,
                                        postSearchText: postSearchText)
                case .NavigationProfile(let postUserName,
                                        let postUserID,
                                        let usedTo):
                    NavigationProfileView(postUserName: postUserName,
                                          postUserID: postUserID,
                                          usedTo: usedTo)
                case .Record(let recordType):
                    RecordView(recordType: recordType)
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
            .onAppear {
                appViewModel.tabBarState = .visible
            }
        }
        .environmentObject(navigationRouter)
        .toolbar(appViewModel.tabBarState, for: .tabBar)
    }
}

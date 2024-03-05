//
//  MyPageView.swift
//  JUDA
//
//  Created by phang on 2/27/24.
//

import SwiftUI

struct MyPageView: View {
    @StateObject private var navigationRouter = NavigationRouter()
    @EnvironmentObject private var authService: AuthService

    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            VStack {
                if authService.signInStatus {
                    AuthenticatedMypageView()
                } else {
                    UnauthenticatedMypageView()
                }
            }
            .navigationDestination(for: Route.self) { value in
                switch value {
                case .ChangeUserName:
                    ChangeUserNameView()
                        .modifier(TabBarHidden())
                case .AddTag:
                    AddTagView()
                        .modifier(TabBarHidden())
                case .AlarmStore:
                    AlarmStoreView()
                        .modifier(TabBarHidden())
                case .Setting:
                    SettingView()
                        .modifier(TabBarHidden())
                case .Login:
                    LogInView()
                        .modifier(TabBarHidden())
                case .Notice:
                    NoticeView()
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
                                 let usedTo,
                                 let postPhotosURL):
                    PostDetailView(postUserType: postUserType,
                                   post: post,
                                   usedTo: usedTo,
                                   postPhotosURL: postPhotosURL)
                    .modifier(TabBarHidden())
                default:
                    ErrorPageView()
                        .modifier(TabBarHidden())
                }
            }
        }
        .environmentObject(navigationRouter)
    }
}


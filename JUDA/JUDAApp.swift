//
//  JUDAApp.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/22.
//

import SwiftUI

@main
struct JUDAApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var myPageViewModel = MyPageViewModel()
    @StateObject private var drinkViewModel = DrinkViewModel()
    @StateObject private var postsViewModel = PostsViewModel()
    @StateObject private var colorScheme = SystemColorTheme()
    @StateObject private var weatherViewModel = WeatherViewModel()
    @StateObject private var aiViewModel = AiViewModel()
    @StateObject private var searchPostsViewModel = SearchPostsViewModel()
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                SplashView(isActive: $isLoading)
                    .environmentObject(authService)
                    .environmentObject(colorScheme)
                    .environmentObject(mainViewModel)
                    .environmentObject(aiViewModel)
                    .environmentObject(weatherViewModel)
                    .environmentObject(appViewModel)
                    .environmentObject(searchPostsViewModel)
            } else {
                ContentView()
                    .environmentObject(authService)
                    .environmentObject(appViewModel)
                    .environmentObject(colorScheme)
                    .environmentObject(mainViewModel)
                    .environmentObject(myPageViewModel)
                    .environmentObject(postsViewModel)
                    .environmentObject(drinkViewModel)
                    .environmentObject(aiViewModel)
                    .environmentObject(weatherViewModel)
                    .environmentObject(searchPostsViewModel)
            }
        }
    }
}

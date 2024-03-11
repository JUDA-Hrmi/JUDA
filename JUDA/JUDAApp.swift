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
    @StateObject private var authViewModel = AuthViewModel()
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var mainViewModel = MainViewModel()
    @StateObject private var drinkViewModel = DrinkViewModel()
    @StateObject private var postViewModel = PostViewModel()
    @StateObject private var colorScheme = SystemColorTheme()
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                SplashView(isActive: $isLoading)
                    .environmentObject(authViewModel)
                    .environmentObject(colorScheme)
                    .environmentObject(mainViewModel)
                    .environmentObject(appViewModel)
            } else {
                ContentView()
                    .environmentObject(authViewModel)
                    .environmentObject(appViewModel)
                    .environmentObject(colorScheme)
                    .environmentObject(mainViewModel)
                    .environmentObject(postViewModel)
                    .environmentObject(drinkViewModel)
            }
        }
    }
}

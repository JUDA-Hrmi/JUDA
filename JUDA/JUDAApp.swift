//
//  JUDAApp.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/22.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // firebase
        FirebaseApp.configure()
        return true
    }
}

@main
struct JUDAApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var authService = AuthService()
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var colorScheme = BackgroundTheme()
    @State private var isLoading = true
    
    var body: some Scene {
        WindowGroup {
            if isLoading {
                SplashView(isActive: $isLoading)
                    .environmentObject(authService)
            } else {
                ContentView()
                    .environmentObject(authService)
                    .environmentObject(appViewModel)
                    .environmentObject(colorScheme)
            }
        }
    }
}

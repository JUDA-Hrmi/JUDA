//
//  JUDAApp.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/22.
//

import SwiftUI
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // 파이어베이스 설정
        FirebaseApp.configure()
        
        // 앱 실행 시 사용자에게 알림 허용 권한을 받음
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound] // 필요한 알림 권한을 설정
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // UNUserNotificationCenterDelegate를 구현한 메서드를 실행시킴
        application.registerForRemoteNotifications()
        
        // 파이어베이스 Meesaging 설정
        Messaging.messaging().delegate = self
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // 백그라운드에서 푸시 알림을 탭했을 때 실행
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("APNS token: \(deviceToken)")
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // Foreground에서도 알림 오는 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
    }
}

extension AppDelegate: MessagingDelegate {
    // 파이어베이스 MessagingDelegate 설정
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        // TODO: 로그인 안되어있을 때도 알람이 오는 것이 문제다.(일단 킵)
        // 기기별 FCM Token users 컬렉션 - fcmToken 필드로 저장
        if let userId = Auth.auth().currentUser?.uid {
            let db = Firestore.firestore()
            let userRef = db.collection("users").document(userId)
            
            userRef.setData(["fcmToken":fcmToken ?? ""], merge: true) { error in
                if let error = error {
                    print(error)
                } else {
                    print("FCM Tokens saved Successfully.")
                }
            }
        }
        
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: dataDict
        )
    }
}

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
            }
        }
    }
}

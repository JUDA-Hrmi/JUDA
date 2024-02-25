//
//  MypageViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import Firebase
import FirebaseFirestore

//class Users: ObservableObject {
//    static let shared = Users()
//    private init() {}
//    @Published var users = [User]()
//    let db = Firestore.firestore()
//    private var listener: ListenerRegistration?
//    
//    @MainActor
//    func fetchNotificationAllowed() async {
//        
//    }
// 
//}

class Alarms: ObservableObject {
    static let shared = Alarms()
    private init() {}
    @Published var alarms = [Alarm]()
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @MainActor
    func fetchLikedUserName(userId: String) async {
        do {
            let alarmSnapshot = try await db.collection("users").document(userId).collection("notificationList").getDocuments()

            for document in alarmSnapshot.documents {
                if let likedUserID = document["likedUserId"] as? String {
                    do {
                        let userSnapshot = try await db.collection("users").document(likedUserID).getDocument()
                        
                        if let userName = userSnapshot.data()?["name"] as? String {
                            print(userName)
                            let notification = Alarm(userName: userName)
                            self.alarms.append(notification)
                        }
                    } catch {
                        print("Error: \(error)")
                    }
                }
            }
        } catch {
            print("Error: \(error)")
        }
    }
}

//struct NotificationListView: View {
//    @State private var notifications: [NotificationModel] = []
//
//    var body: some View {
//        List(notifications) { notification in
//            Text(notification.userName)
//            // 여기에 다른 notification 관련 정보를 표시할 수 있음
//        }
//        .onAppear {
//            fetchNotifications()
//        }
//    }
//
//    private func fetchNotifications() {
//        // Firebase 초기화
//        FirebaseApp.configure()
//
//        // Firestore 초기화
//        let db = Firestore.firestore()
//
//        // Firestore에서 데이터 가져오기
//        db.collection("users").document("yourUserID").collection("notificationList").getDocuments { snapshot, error in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                // 성공적으로 데이터를 가져왔을 때
//                for document in snapshot!.documents {
//                    if let likedUserID = document["likedUserID"] as? String {
//                        // likedUserID를 사용하여 users 컬렉션에서 해당 사용자 정보 가져오기
//                        db.collection("users").document(likedUserID).getDocument { userSnapshot, userError in
//                            if let userError = userError {
//                                print("Error getting user document: \(userError)")
//                            } else {
//                                // 성공적으로 사용자 정보를 가져왔을 때
//                                if let userName = userSnapshot?.data()?["name"] as? String {
//                                    let notification = NotificationModel(userName: userName)
//                                    // 다른 필요한 notification 정보를 여기에 추가
//                                    notifications.append(notification)
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}

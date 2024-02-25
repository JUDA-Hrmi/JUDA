//
//  MypageViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class AlarmViewModel: ObservableObject {
    @Published var notifications = [NotificationField]()
    @Published var alarms = [Alarm]()
    
    @Published var likedUserID: String = ""
    @Published var postId: String = ""
    @Published var likedTime: Date = Date()
    @Published var userName: String = ""
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @MainActor
    func fetchNotificationList(userId: String) async {
        do {
            let alarmSnapshot = try await db.collection("users").document(userId).collection("notificationList").getDocuments()
            
            self.notifications.removeAll()
            
            for alarmDocument in alarmSnapshot.documents {
                if let notification = try? alarmDocument.data(as: NotificationField.self) {
                    self.notifications.append(notification)
                    print("notification: ", notification)
                }
                
                if let likedUserID = alarmDocument["likedUserId"] as? String {
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
            print(alarms)
            print(notifications)
        } catch {
            print("Error fetching posts:", error)
        }
    }
}


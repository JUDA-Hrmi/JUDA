//
//  MypageViewModel.swift
//  JUDA
//
//  Created by 홍세희 on 2024/01/24.
//

import Foundation
import Firebase
import FirebaseFirestore

class Users: ObservableObject {
    static let shared = Users()
    private init() {}
    @Published var users = [User]()
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @MainActor
    func fetchNotificationAllowed() async {
        
    }
 
}

class Alarms: ObservableObject {
    static let shared = Alarms()
    private init() {}
    @Published var alarms = [Alarm]()
    let db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    @MainActor
    func fetchNotificationForUser(userId: String) async {
        do {
            let alarmSnapshot = try await db.collection("users").document(userId).collection("notificationList").getDocuments()
            
            for alarmDocument in alarmSnapshot.documents {
                if let notification = try? alarmDocument.data(as: Alarm.self) {
                    self.alarms.append(notification)
                    print("notification: ", notification)
                }
            }
        } catch {
            print("Error fetching posts:", error)
        }
    }
}

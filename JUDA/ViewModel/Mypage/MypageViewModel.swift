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
    
//    func startListeningForUser(_ userId: String) {
//           // 기존 리스너가 있다면 삭제
//           listener?.remove()
//
//           // 새로운 리스너 등록
//           let userRef = db.collection("users").document(userId)
//           listener = userRef.addSnapshotListener { [weak self] documentSnapshot, error in
//               guard let self = self else { return }
//
//               if let error = error {
//                   print("Error fetching document: \(error)")
//                   return
//               }
//
//               guard let documentSnapshot = documentSnapshot else {
//                   print("Document does not exist")
//                   return
//               }
//
//               do {
//                   if let updatedUser = try documentSnapshot.data(as: User.self) {
//                           if let index = self.users.firstIndex(where: { $0.id == userId }) {
//                               // Update the user in the array
//                               self.users[index] = updatedUser
//                           } else {
//                               // Add the user to the array
//                               self.users.append(updatedUser)
//                           }
//                       }
//               } catch {
//                   print("Error decoding user data:", error)
//               }
//           }
//       }
    // TODO: 업데이트 함수 작성하기
    func updateUserName(userId: String, userName: String) {
        let docRef = db.collection("users").document(userId)

        docRef.updateData(["name": userName]) { error in
            if let error = error {
                print(error)
            } else {
                print("Successed merged in:", userId)
            }
        }
    }
    
//    func fetchPostsForUser(userId: String) async {
//            do {
//                let postsSnapshot = try await db.collection("users").document(userId).collection("posts").getDocuments()
//
//                var posts = [Post]()
//
//                for postDocument in postsSnapshot.documents {
//                    if let post = try? postDocument.data(as: Post.self) {
//                        posts.append(post)
//                        print("Post content:", post.content)
//                    }
//                }
//            } catch {
//                print("Error fetching posts:", error)
//            }
//        }
    
    // 컬렉션에서 여러 문서 가져오기
    @MainActor
    func fetchAllUsers() async {
        do {
            let snapshot = try await db.collection("users").getDocuments()
            
            // 이거 안해주면 load 할 때마다 와랄라 다 출력된다!
            self.users.removeAll()
            
            for document in snapshot.documents {
                if let user = try? document.data(as: User.self) {
                    self.users.append(user)
                    print("data", user)
                }
            }
        } catch {
            print(error)
        }
    }
    
    // 특정 사용자만 불러오기
    @MainActor
    func fetchUserInformation(userId: String) async {
        do {
            let document = try await db.collection("users").document(userId).getDocument()
            self.users.removeAll()
            if let user = try? document.data(as: User.self) {
                // 이전 데이터를 유지하지 않도록 변경
                self.users = [user]
                print("Data:", user)
            }
        } catch {
            print(error)
        }
    }
    
    func findUserInformation(name: String) async {
        do {
            let snapshot = try await db.collection("users").whereField("name", isEqualTo: name).getDocuments()
            self.users.removeAll()
            for document in snapshot.documents {
                print("data:", document.data())
                if let user = try? document.data(as: User.self) {
                    self.users.append(user)
                }
            }
        } catch {
            print(error)
        }
    }
    
    // 실시간 업데이트 수신 대기
    func startListening() {
        listener =
        db.collection("users").addSnapshotListener { snapshot, error in
            guard let snapshot = snapshot, error == nil else {
                print("Error fetching snapshots: \(error!)")
                return
            }
            snapshot.documentChanges.forEach { diff in
                if diff.type == .added {
                    if let user = try? diff.document.data(as: User.self) {
                        self.users.append(user)
                        print("[add data]", user)
                    }
                }
                if diff.type == .modified {
                    if let user = try? diff.document.data(as: User.self) {
                        for (index, item) in self.users.enumerated() where user.name  == item.name {
                            self.users[index] = user
                            print("[modified data]", user)
                        }
                    }
                }
                if diff.type == .removed {
                    if let user = try? diff.document.data(as: User.self) {
                        for (index, item) in self.users.enumerated() where user.name == item.name {
                            self.users.remove(at: index)
                            print("[removed data]", user)
                        }
                    }
                }
            }
        }
        print("start Listening")
    }
    // 특정 사용자의 변화만 감지하기
//    func startListeningForUser(userId: String) {
//        listener =
//        db.collection("users").document(userId).addSnapshotListener { documentSnapshot, error in
//            guard let documentSnapshot = documentSnapshot, error == nil else {
//                print("Error fetching document: \(error!)")
//                return
//            }
//
//            if documentSnapshot.exists {
//                // 사용자 문서가 존재할 때만 처리
//                if let updatedUser = try? documentSnapshot.data(as: User.self) {
//                    print("[change data]", updatedUser)
//
//                    // 변경된 사용자 데이터를 처리
//                    if let index = self.users.firstIndex(where: { $0.id == userId }) {
//                        // 사용자를 찾아서 업데이트
//                        self.users[index] = updatedUser
//                        print("[modified data]", updatedUser)
//                    } else {
//                        // 사용자를 찾을 수 없는 경우 추가
//                        self.users.append(updatedUser)
//                        print("[add data]", updatedUser)
//
//                    }
//                }
//            } else {
//                // 문서가 삭제된 경우
//                if let index = self.users.firstIndex(where: { $0.id == userId }) {
//                    self.users.remove(at: index)
//                    print("[removed data]")
//                }
//            }
//        }
//        print("start Listening for user:", userId)
//    }
    // 실시간 관찰 중지
    func stopListening() {
        listener?.remove()
        print("stop Listening")
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

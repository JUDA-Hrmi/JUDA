//
//  UserService.swift
//  JUDA
//
//  Created by phang on 3/7/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth

// MARK: - User ( 타 유저 데이터 받기 )
@MainActor
final class UserService: ObservableObject {
    // 유저
    @Published var user: User?
    // Firebase User ViewModel
    private let firebaseUserViewModel = FirebaseUserViewModel()
    
    // 유저 데이터 받아오기 ( 본인 X / 타 유저 )
    func getUser(uid: String) async {
        user = nil
        await withTaskGroup(of: Void.self) { taskGroup in
            // UserField 받아오기
            taskGroup.addTask { await self.getUserField(uid: uid) }
            // Posts 받아오기
            taskGroup.addTask { await self.getUserPosts(uid: uid) }
            // LikedPosts 받아오기
            taskGroup.addTask { await self.getUserLikedPosts(uid: uid) }
            // LikedDrinks 받아오기
            taskGroup.addTask { await self.getUserLikedDrinks(uid: uid) }
            // Notifications 받아오기
            taskGroup.addTask { await self.getUserNotifications(uid: uid) }
        }
    }
    
    // UserField 받아오기
    private func getUserField(uid: String) async {
        do {
            user?.userField = try await firebaseUserViewModel.fetchUserFieldData(uid: uid)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Posts 받아오기
    private func getUserPosts(uid: String) async {
        do {
            user?.posts = try await firebaseUserViewModel.fetchUserWrittenPosts(uid: uid)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // LikedPosts 받아오기
    private func getUserLikedPosts(uid: String) async {
        do {
            user?.likedPosts = try await firebaseUserViewModel.fetchUserLikedPosts(uid: uid)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // LikedDrinks 받아오기
    private func getUserLikedDrinks(uid: String) async {
        do {
            user?.likedDrinks = try await firebaseUserViewModel.fetchUserLikedDrink(uid: uid)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // Notifications 받아오기
    private func getUserNotifications(uid: String) async {
        do {
            user?.notifications = try await firebaseUserViewModel.fetchUserNotifications(uid: uid)
        } catch {
            print(error.localizedDescription)
        }
    }
}

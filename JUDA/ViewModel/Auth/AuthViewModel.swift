//
//  AuthViewModel.swift
//  JUDA
//
//  Created by phang on 3/4/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import CryptoKit
import AuthenticationServices

// MARK: - Auth Provider Option
enum AuthProviderOption: String {
    case apple = "apple.com"
    case google = "google.com"
    case email = "password"
}

// MARK: - User Liked List (Posts / Drinks) Type
enum UserLikedListType: String {
    case posts = "likedPosts"
    case drinks = "likedDrinks"
}

// MARK: - Auth ( 로그인 / 로그아웃 / 탈퇴 / 본인 계정 )
@MainActor
final class AuthViewModel: ObservableObject {
    // 로그인 유무
    @AppStorage("signInStatus") var signInStatus: Bool = false
    // 신규 유저 or 기존 유저
    @Published var isNewUser: Bool = false
    // 현재 유저
    @Published var currentUser: User?
    // 로딩 중
    @Published var isLoading: Bool = false
    // Error
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    // Nonce : 암호와된 임의의 난수
    private var currentNonce: String?
    // Firebase Auth Service
    private let firebaseAuthService = FirebaseAuthService()
    // Firebase User Service
    private let firebaseUserService = FirebaseUserService()
    // FireStorage Service
    private let fireStorageService = FireStorageService()
    
    init() {
        Task {
            if signInStatus { await getCurrentUser() }
        }
    }
    
    
    // 현재 유저 있는지 확인, uid 받기
    private func checkCurrentUserID() throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("error :: currentUser 없음")
            defer {
                signOut()
            }
            throw AuthManagerError.noUserID
        }
        return uid
    }
    
    // provider 받아오기 ( AuthProviderOption - rawValue )
    func getProviderOptionString() throws -> String {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw AuthManagerError.noProviderData
        }
        var providers: [String] = []
        for provider in providerData {
            providers.append(provider.providerID)
        }
        guard let authProviderOptionString = providers.first else {
            throw AuthManagerError.noProviderData
        }
        return authProviderOptionString
    }
    
    // 현재 CurrentUser : User 가져오기
    func getCurrentUser() async {
        do {
            let uid = try checkCurrentUserID()
            
            await withTaskGroup(of: Void.self) { taskGroup in
                // 현재 유저 UserField 받아오기
                taskGroup.addTask { await self.getCurrentUserField(uid: uid) }
                // 현재 유저 Posts 받아오기
                taskGroup.addTask { await self.getCurrentUserPosts(uid: uid) }
                // 현재 유저 LikedPosts 받아오기
                taskGroup.addTask { await self.getCurrentUserLikedPosts(uid: uid) }
                // 현재 유저 LikedDrinks 받아오기
                taskGroup.addTask { await self.getCurrentUserLikedDrinks(uid: uid) }
                // 현재 유저 Notifications 받아오기
                taskGroup.addTask { await self.getCurrentUserNotifications(uid: uid) }
            }
        } catch {
            showError = true
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
    
    // 현재 유저 UserField 받아오기
    private func getCurrentUserField(uid: String) async {
        do {
            currentUser?.userField = try await firebaseUserService.fetchUserFieldData(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
    
    // 현재 유저 Posts 받아오기
    private func getCurrentUserPosts(uid: String) async {
        do {
            currentUser?.posts = try await firebaseUserService.fetchUserWrittenPosts(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
    
    // 현재 유저 LikedPosts 받아오기
    private func getCurrentUserLikedPosts(uid: String) async {
        do {
            currentUser?.likedPosts = try await firebaseUserService.fetchUserLikedPosts(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
    
    // 현재 유저 LikedDrinks 받아오기
    private func getCurrentUserLikedDrinks(uid: String) async {
        do {
            currentUser?.likedDrinks = try await firebaseUserService.fetchUserLikedDrink(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
    
    // 현재 유저 Notifications 받아오기
    private func getCurrentUserNotifications(uid: String) async {
        do {
            currentUser?.notifications = try await firebaseUserService.fetchUserNotifications(uid: uid)
        } catch {
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
    }
    
    // 로그아웃
    func signOut() {
        do {
            try Auth.auth().signOut()
            resetData()
        } catch {
            errorMessage = "로그아웃에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
        }
    }
    
    // 데이터 초기화
    func resetData() {
        signInStatus = false
        currentUser = nil
        isLoading = false
        isNewUser = false
    }
    
    // 유저가 좋아하는 술 리스트에 추가 or 삭제
    func addOrRemoveToLikedDrinks(isLiked: Bool, sellectedDrink: Drink) {
        if !isLiked { // 좋아요 X -> O
            currentUser?.likedDrinks.removeAll { $0.drinkField.drinkID == sellectedDrink.drinkField.drinkID }
        } else { // 좋아요 O -> X
            if let user = currentUser,
               !user.likedDrinks.contains(where: { $0.drinkField.drinkID == sellectedDrink.drinkField.drinkID }) {
                currentUser?.likedDrinks.append(sellectedDrink)
            }
        }
    }
    
    // 닉네임 수정
    func updateUserName(userName: String) async {
        do {
            let uid = try checkCurrentUserID()
            await firebaseAuthService.updateUserName(uid: uid, userName: userName)
        } catch {
            showError = true
            errorMessage = "닉네임 변경에 문제가 발생했어요.\n다시 시도해주세요."
        }
    }
    
    // 실시간 업데이트 리스너 등록
    func startListeningForUserField() async {
        do {
            let uid = try checkCurrentUserID()
            firebaseAuthService.startListeningForUser(uid: uid) { user in
                if let user = user {
                    self.currentUser?.userField = user
                }
            }
        } catch {
            print("error :: startListeningForUserField :", error.localizedDescription)
        }
    }
    
    // 유저 정보 저장
    func addUserDataToStore(userData: UserField) {
        do {
            let uid = try checkCurrentUserID()
            firebaseAuthService.addUserDataToStore(userData: userData, uid: uid)
        } catch {
            print("error :: addUserDataToStore :", error.localizedDescription)
        }
    }
    
    // 유저 정보 업데이트 - LikedPosts / LikedDrinks
    func userLikedListUpdate(type: UserLikedListType) async {
        do {
            let uid = try checkCurrentUserID()
            var list = [Any]()
            switch type {
            case .posts:
                list = currentUser?.likedPosts ?? [] as [Post]
            case .drinks:
                list = currentUser?.likedDrinks ?? [] as [Drink]
            }
            await firebaseAuthService.userLikedListUpdate(uid: uid,
                                                      documentName: type.rawValue,
                                                      list: list)
        } catch {
            print("error :: userLiked\(type)Update :", error.localizedDescription)
        }
    }
    
    // 유저 가입 시, 프로필 이미지 올리기 + 이미지 URL 저장
    func uploadProfileImageToStorage(image: UIImage?) async {
        do {
            let uid = try checkCurrentUserID()
            guard let image = image else {
                print("error :: uploadProfileImageToStorage : image X")
                return
            }
            try await fireStorageService.uploadImageToStorage(folder: .user, image: image, fileName: uid)
            // 유저 프로필 받아오기
            let url = try await fireStorageService.fetchImageURL(folder: .user, fileName: uid)
            currentUser?.userField.profileImageURL = url
        } catch {
            print("error :: uploadProfileImageToStorage :", error.localizedDescription)
        }
    }
}

// MARK: - Apple
extension AuthViewModel {
    // 로그인 request
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let signInWithAppleHelper = SignInWithAppleHelper()
        request.requestedScopes = [.fullName, .email]
        let nonce = signInWithAppleHelper.randomNonceString()
        currentNonce = nonce
        request.nonce = signInWithAppleHelper.sha256(nonce)
    }
    
    // 로그인 completion
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                print("error :: appleIDCredential")
                return
            }
            let fullName = appleIDCredential.fullName
            currentUser?.userField.name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            Task {
                // 로그인 중 -
                isLoading = true
                // 로그인
                await signInApple(appleIDCredential: appleIDCredential)
                //
                let uid = try checkCurrentUserID()
                // 신규 유저 체크
                isNewUser = await firebaseAuthService.isNewUser(uid: uid)
                // 신규 유저
                if isNewUser {
                    signOut()
                    self.isNewUser = true
                    print("Fisrt ✨ - Apple Sign Up 🍎")
                } else {
                    print("Apple Sign In 🍎")
                    await getCurrentUserField(uid: uid)
                    self.signInStatus = true
                }
            }
        case .failure(_):
            resetData()
            errorMessage = "로그인에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
        }
    }
    
    // 로그인
    func signInApple(appleIDCredential: ASAuthorizationAppleIDCredential) async {
        await firebaseAuthService.signInApple(appleIDCredential: appleIDCredential,
                                                currentNonce: currentNonce)
    }
    
    // 회원가입 or 회원탈퇴 시, 재 로그인 - Apple
    func reauthApple() async -> ASAuthorizationAppleIDCredential? {
        do {
            let signInWithAppleHelper = SignInWithAppleHelper()
            let appleIDCredential = try await signInWithAppleHelper()
            return appleIDCredential
        } catch {
            errorMessage = "작업에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
            return nil
        }
    }
    
    // 회원탈퇴 - Apple
    func deleteAppleAccount() async -> Bool {
        do {
            guard try getProviderOptionString() == AuthProviderOption.apple.rawValue else { return false }
            try await firebaseAuthService.deleteAccountWithApple()
            resetData()
            isLoading = false
            return true
        } catch {
            print("error :: \(error.localizedDescription)")
            errorMessage = "회원탈퇴에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
            isLoading = false
            return false
        }
    }
}

// MARK: - Google
extension AuthViewModel{
    // 로그인
    func signInWithGoogle() async {
        do {
            let signInWithGoogleHelper = SignInWithGoogleHelper()
            let token = try await signInWithGoogleHelper.signIn()
            // Firebase auth
            let credential = GoogleAuthProvider.credential(
                withIDToken: token.idToken,
                accessToken: token.accessToken
            )
            // 로그인 중 -
            isLoading = true
            // sign in
            try await Auth.auth().signIn(with: credential)
            //
            let uid = try checkCurrentUserID()
            // 신규 유저 체크
            isNewUser = await firebaseAuthService.isNewUser(uid: uid)
            // 신규 유저
            if isNewUser {
                self.isNewUser = true
                print("Fisrt ✨ - Google Sign Up 🤖")
            } else {
                print("Google Sign In 🤖")
                await getCurrentUserField(uid: uid)
                self.signInStatus = true
            }
        } catch {
            print("error :: \(error.localizedDescription)")
            errorMessage = "로그인에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
            resetData()
        }
    }
    
    // 회원탈퇴 - Google
    func deleteGoogleAccount() {
        // TODO: - 구글 탈퇴 추가
    }
}

//
//  AuthManager.swift
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

// MARK: - Auth
@MainActor
//final class AuthManager: ObservableObject {
final class AuthService: ObservableObject {
    // 로그인 유무
    @AppStorage("signInStatus") var signInStatus: Bool = false
    // 신규 유저 or 기존 유저
    @Published var isNewUser: Bool = false
    // 현재 유저
    @Published var currentUser: UserField?
    // 로딩 중
    @Published var isLoading: Bool = false
    // Error
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    // Nonce : 암호와된 임의의 난수
    private var currentNonce: String?
    // Firebase Auth ViewModel
    private let firebaseAuthViewModel = FirebaseAuthViewModel()
    // Firestorage Auth ViewModel
    private let firestorageAuthViewModel = FirestorageAuthViewModel()
    
    init() {
        Task {
            if signInStatus { await getAuthUser() }
        }
    }
    
    // 현재 유저 있는지 확인, uid 받기
    private func checkCurrentUserID() throws -> String {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("currentUser 없음")
            defer {
                signOut()
            }
            throw AuthManagerError.noUserID
        }
        return uid
    }
    
    // provider 확인
    func getProvider() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw AuthManagerError.noProviderData
        }
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                assertionFailure("Provider Option Not Found \(provider.providerID)")
            }
        }
        return providers
    }
    
    // 현재 유저 받아오기
    func getAuthUser() async {
        do {
            let uid = try checkCurrentUserID()
            currentUser = try await firebaseAuthViewModel.fetchUserData(uid: uid)
            await fetchProfileImage()
        } catch {
            showError = true
            errorMessage = error.localizedDescription
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
    func addOrRemoveToLikedDrinks(isLiked: Bool, _ drinkID: String?) {
        guard let drinkID = drinkID else {
            print("addOrRemoveToLikedDrinks - 술 ID 없음")
            return
        }
        if !isLiked { // 좋아요 X -> O
            currentUser?.likedDrinks.removeAll { $0 == drinkID }
        } else { // 좋아요 O -> X
            if let user = currentUser,
               !user.likedDrinks.contains(drinkID) {
                currentUser?.likedDrinks.append(drinkID)
            }
        }
    }
    
    // 닉네임 수정
    func updateUserName(userName: String) async {
        do {
            let uid = try checkCurrentUserID()
            try await firebaseAuthViewModel.updateUserName(uid: uid, userName: userName)
        } catch {
            showError = true
            errorMessage = "닉네임 변경에 문제가 발생했어요.\n다시 시도해주세요."
        }
    }
    
    // 실시간 업데이트 리스너 등록
    func startListeningForUser() async {
        do {
            let uid = try checkCurrentUserID()
            firebaseAuthViewModel.startListeningForUser(uid: uid) { user in
                if let user = user {
                    self.currentUser = user
                }
            }
        } catch {
            print("startListeningForUser :", error.localizedDescription)
        }
    }
    
    // 유저 정보 저장
    func addUserDataToStore(userData: UserField) {
        do {
            let uid = try checkCurrentUserID()
            firebaseAuthViewModel.addUserDataToStore(userData: userData, uid: uid)
        } catch {
            print("addUserDataToStore :", error.localizedDescription)
        }
    }
    
    // 유저 정보 업데이트 - posts / drinks
    func userLikedListUpdate(type: UserLikedListType) {
        do {
            let uid = try checkCurrentUserID()
            var list = [String]()
            switch type {
            case .posts:
                list = currentUser?.likedPosts ?? []
            case .drinks:
                list = currentUser?.likedDrinks ?? []
            }
            firebaseAuthViewModel.userLikedListUpdate(uid: uid,
                                                      documentName: type.rawValue,
                                                      list: list)
        } catch {
            print("userLiked\(type)Update :", error.localizedDescription)
        }
    }
    
    // 유저 가입 시, 프로필 이미지 올리기
    func uploadProfileImageToStorage(image: UIImage?) {
        do {
            let uid = try checkCurrentUserID()
            guard let image = image else {
                print("error - uploadProfileImageToStorage : image X")
                return
            }
            firestorageAuthViewModel.uploadProfileImageToStorage(image: image, uid: uid)
        } catch {
            print("uploadProfileImageToStorage :", error.localizedDescription)
        }
    }
    
    // 유저 프로필 받아오기
    func fetchProfileImage() async {
        do {
            let uid = try checkCurrentUserID()
            currentUser?.profileURL = try await firestorageAuthViewModel.fetchProfileImage(uid: uid)
        } catch {
            print("fetchProfileImage :", error.localizedDescription)
        }
    }
}

// MARK: - Apple
//extension AuthManager {
extension AuthService {
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
                print("error: appleIDCredential")
                return
            }
            let fullName = appleIDCredential.fullName
            currentUser?.name = (fullName?.familyName ?? "") + (fullName?.givenName ?? "")
            Task {
                // 로그인 중 -
                isLoading = true
                // 로그인
                await signInApple(appleIDCredential: appleIDCredential)
                //
                let uid = try checkCurrentUserID()
                // 신규 유저 체크
                isNewUser = await firebaseAuthViewModel.isNewUser(uid: uid)
                // 신규 유저
                if isNewUser {
                    signOut()
                    self.isNewUser = true
                    print("Fisrt ✨ - Apple Sign Up 🍎")
                } else {
                    print("Apple Sign In 🍎")
                    await getAuthUser()
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
        await firebaseAuthViewModel.signInApple(appleIDCredential: appleIDCredential,
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
            guard try getProvider().contains(.apple) == true else { return false }
            try await firebaseAuthViewModel.deleteAccountWithApple()
            resetData()
            isLoading = false
            return true
        } catch {
            print("deleteAccount error : \(error.localizedDescription)")
            errorMessage = "회원탈퇴에 문제가 발생했어요.\n다시 시도해주세요."
            showError = true
            isLoading = false
            return false
        }
    }
}

// MARK: - Google
//extension AuthManager {
extension AuthService {
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
            isNewUser = await firebaseAuthViewModel.isNewUser(uid: uid)
            // 신규 유저
            if isNewUser {
                self.isNewUser = true
                print("Fisrt ✨ - Google Sign Up 🤖")
            } else {
                print("Google Sign In 🤖")
                await getAuthUser()
                self.signInStatus = true
            }
        } catch {
            print("error - \(error.localizedDescription)")
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

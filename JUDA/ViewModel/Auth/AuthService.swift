//
//  AuthService.swift
//  JUDA
//
//  Created by phang on 2/13/24.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import CryptoKit
import AuthenticationServices

// MARK: - 로그인 / Auth
@MainActor
final class AuthService: ObservableObject {
    // 로그인 유무
    @AppStorage("signInStatus") var signInStatus: Bool = false
    // 신규 유저 or 기존 유저
    @AppStorage("isFirstSignIn") var isFirstSignIn: Bool = false
    // User Data
    @Published var name: String = ""
    @Published var age: String = ""
    @Published var gender: String = ""
    @Published var profileImage: String = ""
    @Published var notificationAllowed: Bool = false
    // Error
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    // 로그인 중
    @Published var signInButtonClicked: Bool = false
    // Nonce : 암호와된 임의의 난수
    private var currentNonce: String?
    
    // 로그아웃
    func signOut() {
        do {
          try Auth.auth().signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        self.signInStatus = false
    }
    
    // 회원탈퇴 - Apple
    func deleteAccount() async -> Bool {
        guard let user = Auth.auth().currentUser else { return false }
        let needsTokenRevocation = user.providerData.contains { $0.providerID == "apple.com" }
        do {
            if needsTokenRevocation {
                let signInWithApple = SignInWithApple()
                let appleIDCredential = try await signInWithApple()
                
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("ID 토큰 가져오지 못함")
                    return false
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("데이터 -> 토큰 문자열 에러 : \(appleIDToken.debugDescription)")
                    return false
                }
                
                let nonce = randomNonceString()
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                try await user.reauthenticate(with: credential)
                // 애플에서도 앱에 대한 로그인 토큰 삭제
                guard let authorizationCode = appleIDCredential.authorizationCode else { return false }
                guard let authCodeString = String(data: authorizationCode, encoding: .utf8) else { return false }
                try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
            }
            
            let uid = user.uid
            try await user.delete()
            deleteAccountData(uid: uid) // TODO: - Cloud Functions 을 통해서 지우는게 이상적
            signInStatus = false
            errorMessage = ""
            return true
        } catch {
            print("deleteAccount error : \(error.localizedDescription)")
            errorMessage = error.localizedDescription
            return false
        }
    }
}

// MARK: - firestore : 유저 저장 & 유저 삭제
extension AuthService {
    // firestore 에 유저 저장
    func addUserDataToStore(userData: User) {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("current User X")
            return
        }
        let documetnRef = Firestore.firestore().collection("users")
            .document(uid)
        do {
            try documetnRef.setData(from: userData)
            print("Success - 유저 정보 저장")
        } catch {
            print("유저 정보 저장 에러 : \(error.localizedDescription)")
        }
    }
    
    // firestore 에서 유저 데이터 삭제
    func deleteAccountData(uid: String) {
        let reference = Firestore.firestore().collection("users").document(uid)
        reference.delete { error in
            if let error = error {
                print("deleteAccountData - firestore : \(error.localizedDescription)")
                return
            }
        }
    }
}

// MARK: - SignInWithAppleButton : request & result
extension AuthService {
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        signInButtonClicked = true
        request.requestedScopes = [.fullName, .email]
        let nonce = randomNonceString()
        currentNonce = nonce
        request.nonce = sha256(nonce)
    }
    
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    fatalError("Invalid state: a login callback was received, but no login request was sent.")
                }
                guard let appleIDToken = appleIDCredential.identityToken else {
                    print("Unable to fetdch identify token.")
                    return
                }
                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    print("Unable to serialise token string from data: \(appleIDToken.debugDescription)")
                    return
                }
                
                let credential = OAuthProvider.appleCredential(withIDToken: idTokenString,
                                                               rawNonce: nonce,
                                                               fullName: appleIDCredential.fullName)
                Task {
                    do {
                        let result = try await Auth.auth().signIn(with: credential)
                        // 신규 가입의 경우만, displayName 을 넘겨준다.
                        if let displayName = result.user.displayName {
                            print("Fisrt ✨ - Apple Sign In 🍎")
                            self.name = displayName
                            // 약관동의 화면 이동 위해, 신규 가입자로 타입 변경
                            self.isFirstSignIn = true
                        // 기존 유저의 로그인
                        } else {
                            print("Apple Sign In 🍎")
                        }
                        // 로그인 상태 변경
                        withAnimation(.easeInOut) {
                            self.signInStatus = true
                        }
                    }
                    catch {
                        print("Error authenticating: \(error.localizedDescription)")
                    }
                }
            }
        case .failure(let failure):
            signInButtonClicked = false
            errorMessage = failure.localizedDescription
        }
    }
}

// MARK: - Apple Sign In Helper
extension AuthService {
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("nonce 생성 에러 : \(errorCode)")
                }
                return random
            }
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData
            .compactMap { String(format: "%02x", $0) }
            .joined()
      return hashString
    }
}

// MARK: - Sign in with Apple
final class SignInWithApple: NSObject, ASAuthorizationControllerDelegate {
    private var continuation : CheckedContinuation<ASAuthorizationAppleIDCredential, Error>?
    
    func callAsFunction() async throws -> ASAuthorizationAppleIDCredential {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            authorizationController.delegate = self
            authorizationController.performRequests()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if case let appleIDCredential as ASAuthorizationAppleIDCredential = authorization.credential {
            continuation?.resume(returning: appleIDCredential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        continuation?.resume(throwing: error)
    }
}

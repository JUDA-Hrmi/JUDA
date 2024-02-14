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
final class AuthService: ObservableObject {
    // 로그인 유무
    @AppStorage("signInStatus") var signInStatus: Bool = false
    // Error
    @Published var showError: Bool = false
    @Published var errorMessage: String = ""
    // Apple Sign In 사용 - Nonce : 암호와된 임의의 난수
    @Published var nonce: String = ""
    // 로그인 중
    @Published var signInButtonClicked: Bool = false
    
    // Apple Sign In
    func appleAuthenticate(credential: ASAuthorizationAppleIDCredential) {
        guard let appleIDToken = credential.identityToken else {
            print("ID 토큰 가져오지 못함")
            return
        }
        guard let tokenString = String(data: appleIDToken, encoding: .utf8) else {
            print("데이터 -> 토큰 문자열 에러 : \(appleIDToken.debugDescription)")
            return
        }
        let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                  idToken: tokenString,
                                                  rawNonce: nonce)
        // Firebase 로 로그인
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if (error != nil) {
                print(error?.localizedDescription as Any)
                return
            }
            print("Apple Sign In 🍎")
            withAnimation(.easeInOut) {
                self.signInStatus = true
            }
            // 로그인 정보 firestore 에 저장
            self.storeUserInformation()
        }
    }
    
    // 로그아웃
    func signOut() {
        let firebaseAuth = Auth.auth()
        do {
          try firebaseAuth.signOut()
        } catch let signOutError as NSError {
          print("Error signing out: %@", signOutError)
        }
        self.signInStatus = false
    }
    
    // firestore 에 저장
    func storeUserInformation() {
        guard let uid = Auth.auth().currentUser?.uid else { 
            print("current User X")
            return
        }
        let userData: [String: Any] = ["name": "phang", "gender": "male", "age": 32] // TODO: - 실제 유저 데이터로 변경 필요
        Firestore.firestore().collection("users")
            .document(uid).setData(userData) { error in
                if let error = error {
                    print("유저 정보 저장 에러 : \(error.localizedDescription)")
                    return
                }
                print("Success - 유저 정보 저장")
            }
    }
    
    // 탈퇴
//    func deleteCurrentUser() {
//      do {
//        let nonce = try CryptoUtils.randomNonceString()
//        currentNonce = nonce
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = CryptoUtils.sha256(nonce)
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.delegate = self
//        authorizationController.presentationContextProvider = self
//        authorizationController.performRequests()
//      } catch {
//        // In the unlikely case that nonce generation fails, show error view.
//        displayError(error)
//      }
//    }

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

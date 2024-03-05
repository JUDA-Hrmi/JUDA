//
//  SignInWithGoogleHelper.swift
//  JUDA
//
//  Created by phang on 3/4/24.
//

import Foundation
import FirebaseCore
import GoogleSignIn

// MARK: -
struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
}

// MARK: - Sign in with Google
final class SignInWithGoogleHelper {
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            fatalError("No Firebase Client ID")
        }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        // get rootView
        let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        guard let rootViewController = scene?.windows.first?.rootViewController else {
            fatalError("No Root View")
        }
        // google sign in authentication response
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController
        )
        let user = result.user
        guard let idToken = user.idToken?.tokenString else {
            fatalError("No User ID Token")
        }
        let accessToken = user.accessToken.tokenString
        let tokens = GoogleSignInResultModel(idToken: idToken,
                                             accessToken: accessToken)
        return tokens
    }
}

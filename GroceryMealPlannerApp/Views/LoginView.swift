//
//  LoginView.swift
//  GroceryMealPlannerApp
//
//  Created by Andy M on 3/24/26.
//

import SwiftUI
import AuthenticationServices
import CryptoKit

// TODO App Logo
struct LoginView: View {
    @Environment(AppDataStore.self) var dataStore: AppDataStore
    @State private var currentNonce: String?

    var body: some View {
        VStack{
            Text("This Week's Eats")
                .font(AppFont.bold(size: 30))
            SignInWithAppleButton(onRequest: { req in
                let nonce = GeneralUtils.randomNonceString()
                currentNonce = nonce
                req.requestedScopes = [.fullName, .email]
                req.nonce = GeneralUtils.sha256(nonce)
            }, onCompletion: { result in
                switch result {
                case .success(let authorization):
                    guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                          let nonce = currentNonce else { return }
                    Task {
                        await dataStore.signInWithApple(credential: credential, nonce: nonce)
                    }
                case .failure(let error):
                    print("Apple Sign In failed: \(error)")
                }
            })
            .frame(height: 50)
            .padding()
        }
    }
}

#Preview {

    LoginView()
}

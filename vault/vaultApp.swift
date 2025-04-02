//
//  vaultApp.swift
//  vault
//
//  Created by Bryant Huynh on 3/30/25.
//

import SwiftUI
import FirebaseCore
import GoogleSignIn

@main
struct VaultApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
        
        // Initialize Google Sign In
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            print("Error: No client ID found in Firebase configuration")
            return
        }
        
        // Configure Google Sign In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        // Restore previous sign-in if available
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Error restoring previous sign-in: \(error.localizedDescription)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if authViewModel.isAuthenticated {
                MainTabView()
                    .environmentObject(authViewModel)
            } else {
                AuthView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

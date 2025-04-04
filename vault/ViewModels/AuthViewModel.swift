//
//  AuthViewModel.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UIKit
import CommonCrypto

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var error: Error?
    @Published var isDatabaseResetting = false
    
    private let auth = Auth.auth()
    private let coreDataService = CoreDataService.shared
    private let debugDataService = DebugService.shared
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                Task {
                    await self.fetchUser(firebaseUID: user.uid)
                }
            } else {
                self.user = nil
                self.isAuthenticated = false
            }
        }
    }
    
    func resetAndPopulateDatabase() async throws {
        guard let userId = user?.id else {
            throw AuthError.notAuthenticated
        }
        
        isDatabaseResetting = true
        defer { isDatabaseResetting = false }
        
        do {
            // Clean the database
            try await debugDataService.clearDatabase()
            
            // Populate with new data
            try await debugDataService.populateDummyData(for: userId)
            
            // Refresh the user data
            if let firebaseUser = auth.currentUser {
                await fetchUser(firebaseUID: firebaseUser.uid)
            }
        } catch {
            print("Error resetting database: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signInWithGoogle() async throws {
        do {
            // Get the root view controller
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first,
                  let rootViewController = window.rootViewController else {
                print("Error: Could not get root view controller")
                throw AuthError.presentationError
            }
            
            // Sign in with Google
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            // Get the Google ID token and access token
            guard let idToken = result.user.idToken?.tokenString else {
                print("Error: No ID token received from Google")
                throw AuthError.tokenError
            }
            
            // Create Firebase credential
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            // Sign in to Firebase
            let authResult = try await auth.signIn(with: credential)
            
            // Create or update user in CoreData
            try await createOrUpdateUser(authResult.user)
            
        } catch let error as NSError {
            print("Error during Google Sign-In: \(error.localizedDescription)")
            print("Error domain: \(error.domain)")
            print("Error code: \(error.code)")
            self.error = error
            throw error
        }
    }
    
    private func createOrUpdateUser(_ firebaseUser: FirebaseAuth.User) async throws {
        // Create a deterministic UUID from Firebase UID
        let userId = createDeterministicUUID(from: firebaseUser.uid)
        
        // Try to get existing user
        if let existingUser = try? await coreDataService.getUser(id: userId) {
            // Update existing user
            let updatedUser = User(
                id: existingUser.id,
                username: existingUser.username,
                email: firebaseUser.email ?? "",
                passwordHash: existingUser.passwordHash,
                fullName: firebaseUser.displayName ?? existingUser.fullName ?? "",
                registrationDate: existingUser.registrationDate,
                employmentStatus: existingUser.employmentStatus,
                netPaycheckIncome: existingUser.netPaycheckIncome,
                profileImageUrl: existingUser.profileImageUrl,
                monthlyIncome: existingUser.monthlyIncome,
                monthlySavingsGoal: existingUser.monthlySavingsGoal,
                monthlySpendingLimit: existingUser.monthlySpendingLimit,
                friends: existingUser.friends,
                createdAt: existingUser.createdAt,
                updatedAt: Date()
            )
            self.user = try await coreDataService.updateUser(updatedUser)
        } else {
            // Create new user
            let newUser = User(
                id: userId,
                username: firebaseUser.email?.components(separatedBy: "@").first ?? "",
                email: firebaseUser.email ?? "",
                passwordHash: "", // We don't store password hash for Google Sign-In
                fullName: firebaseUser.displayName,
                registrationDate: Date(),
                employmentStatus: "Not Set",
                netPaycheckIncome: 0,
                profileImageUrl: "",
                monthlyIncome: 0,
                monthlySavingsGoal: 0,
                monthlySpendingLimit: 0,
                friends: [],
                createdAt: Date(),
                updatedAt: Date()
            )
            self.user = try await coreDataService.createUser(newUser)
        }
        
        self.isAuthenticated = true
    }
    
    private func fetchUser(firebaseUID: String) async {
        do {
            let userId = createDeterministicUUID(from: firebaseUID)
            if let user = try await coreDataService.getUser(id: userId) {
                self.user = user
                self.isAuthenticated = true
            } else {
                self.error = AuthError.notAuthenticated
                self.isAuthenticated = false
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            self.error = error
            self.isAuthenticated = false
        }
    }
    
    private func createDeterministicUUID(from string: String) -> UUID {
        // Create a deterministic UUID using the namespace UUID for URLs and the Firebase UID
        let namespace = UUID(uuidString: "6ba7b810-9dad-11d1-80b4-00c04fd430c8")! // UUID namespace for URLs
        let data = string.data(using: .utf8)!
        
        var uuid = UUID().uuid // for temporary storage
        
        // Perform UUID v5 (SHA-1) calculation
        withUnsafeMutableBytes(of: &uuid) { destBytes in
            var context = CC_SHA1_CTX()
            CC_SHA1_Init(&context)
            
            // Add namespace
            var namespaceBytes = namespace.uuid
            CC_SHA1_Update(&context, &namespaceBytes, 16)
            
            // Add name
            data.withUnsafeBytes { dataBytes in
                CC_SHA1_Update(&context, dataBytes.baseAddress, CC_LONG(data.count))
            }
            
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
            CC_SHA1_Final(&digest, &context)
            
            // Set version number (5) and variant bits
            digest[6] = (digest[6] & 0x0F) | 0x50 // Version 5
            digest[8] = (digest[8] & 0x3F) | 0x80 // RFC 4122 variant
            
            // Copy first 16 bytes to uuid
            for i in 0..<16 {
                destBytes[i] = digest[i]
            }
        }
        
        return UUID(uuid: uuid)
    }
    
    func signOut() {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
            self.user = nil
            self.isAuthenticated = false
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            self.error = error
        }
    }
}

enum AuthError: Error {
    case configurationError
    case presentationError
    case tokenError
    case notAuthenticated
}

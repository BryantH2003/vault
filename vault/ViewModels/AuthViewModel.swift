import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn
import UIKit

@MainActor
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var error: Error?
    @Published var isDatabaseResetting = false
    
    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()
    private let databaseService = DatabaseService()
    
    init() {
        setupAuthStateListener()
    }
    
    private func setupAuthStateListener() {
        auth.addStateDidChangeListener { [weak self] _, user in
            guard let self = self else { return }
            if let user = user {
                Task {
                    await self.fetchUser(userId: user.uid)
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
            try await databaseService.cleanDatabase()
            
            // Populate with new data
            try await databaseService.populateDummyData(for: userId)
            
            // Refresh the user data
            await fetchUser(userId: userId)
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
            
            // Create or update user in Firestore
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
        let userRef = firestore.collection("users").document(firebaseUser.uid)
        
        // Try to get existing user
        let snapshot = try await userRef.getDocument()
        
        if snapshot.exists {
            // Get existing user data
            if let existingUser = try? snapshot.data(as: User.self) {
                // Update existing user with all required fields
                try await userRef.updateData([
                    "uniqueKey": existingUser.uniqueKey,
                    "email": firebaseUser.email ?? "",
                    "fullName": firebaseUser.displayName ?? "",
                    "profileImageUrl": firebaseUser.photoURL?.absoluteString as Any,
                    "monthlyIncome": existingUser.monthlyIncome,
                    "monthlySavingsGoal": existingUser.monthlySavingsGoal,
                    "monthlySpendingLimit": existingUser.monthlySpendingLimit,
                    "friends": existingUser.friends,
                    "createdAt": existingUser.createdAt,
                    "updatedAt": Date()
                ])
            } else {
                // If we can't decode the existing user, create a new one with the same ID
                let newUser = User(
                    uniqueKey: UUID().uuidString,
                    email: firebaseUser.email ?? "",
                    fullName: firebaseUser.displayName ?? "",
                    profileImageUrl: firebaseUser.photoURL?.absoluteString,
                    monthlyIncome: 0,
                    monthlySavingsGoal: 0,
                    monthlySpendingLimit: 0,
                    friends: [],
                    createdAt: Date(),
                    updatedAt: Date()
                )
                try await userRef.setData(from: newUser)
            }
        } else {
            // Create new user
            let newUser = User(
                uniqueKey: UUID().uuidString,
                email: firebaseUser.email ?? "",
                fullName: firebaseUser.displayName ?? "",
                profileImageUrl: firebaseUser.photoURL?.absoluteString,
                monthlyIncome: 0,
                monthlySavingsGoal: 0,
                monthlySpendingLimit: 0,
                friends: [],
                createdAt: Date(),
                updatedAt: Date()
            )
            
            try await userRef.setData(from: newUser)
        }
        
        // Fetch updated user data
        await fetchUser(userId: firebaseUser.uid)
    }
    
    private func fetchUser(userId: String) async {
        do {
            let document = try await firestore.collection("users").document(userId).getDocument()
            self.user = try document.data(as: User.self)
            self.isAuthenticated = true
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            self.error = error
            self.isAuthenticated = false
        }
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

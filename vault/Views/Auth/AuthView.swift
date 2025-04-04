//
//  AuthView.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//


import SwiftUI

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var startPoint: CGFloat = -1
    @State private var endPoint: CGFloat = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                
                // App Logo and Title
                VStack(spacing: 20) {
                    Image(systemName: "creditcard.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .foregroundColor(.white)
                    
                    Text("Vault")
                        .largeTitleStyle()
                        .overlay {
                            LinearGradient(
                                colors: [.blue, .purple, .pink, .purple, .blue],
                                startPoint: UnitPoint(x: startPoint, y: 0.5),
                                endPoint: UnitPoint(x: endPoint, y: 0.5)
                            )
                            .mask {
                                Text("Vault")
                                    .largeTitleStyle()
                            }
                        }
                        .onAppear {
                            withAnimation(.linear(duration: 4).repeatForever(autoreverses: false)) {
                                startPoint = 1
                                endPoint = 2
                            }
                        }
                    
                    Text("Track your expenses, achieve your goals")
                        .bodyLargeStyle()
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                Spacer()
                
                // Sign In Button
                Button {
                    signInWithGoogle()
                } label: {
                    HStack {
                        Image(systemName: "g.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.blue)
                        
                        Text("Sign in with Google")
                            .buttonLargeStyle()
                    }
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 50)
                .disabled(isLoading)
                
                Spacer()
            }
            
            if isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(.white)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
                .bodyLargeStyle()
        }
    }
    
    private func signInWithGoogle() {
        isLoading = true
        
        Task {
            do {
                try await authViewModel.signInWithGoogle()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            isLoading = false
        }
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}

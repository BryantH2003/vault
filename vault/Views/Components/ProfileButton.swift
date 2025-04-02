import SwiftUI

struct ProfileButton: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showingProfileSheet = false
    
    var body: some View {
        Button(action: { showingProfileSheet.toggle() }) {
            if let profileImageUrl = authViewModel.user?.profileImageUrl,
               let url = URL(string: profileImageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.gray)
            }
        }
        .sheet(isPresented: $showingProfileSheet) {
            NavigationView {
                List {
                    if let user = authViewModel.user {
                        Section {
                            HStack {
                                Text("Name")
                                Spacer()
                                Text(user.fullName)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Text("Email")
                                Spacer()
                                Text(user.email)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Section {
                            Button(role: .destructive, action: {
                                authViewModel.signOut()
                                showingProfileSheet = false
                            }) {
                                HStack {
                                    Text("Sign Out")
                                    Spacer()
                                    Image(systemName: "arrow.right.square")
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Profile")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button("Done") {
                    showingProfileSheet = false
                })
            }
        }
    }
}

#Preview {
    NavigationView {
        ProfileButton()
            .environmentObject(AuthViewModel())
    }
} 
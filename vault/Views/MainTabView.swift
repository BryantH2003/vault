import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            if let user = authViewModel.user {
                DashboardView(userID: user.id)
                    .tabItem {
                        Label("Dashboard", systemImage: "chart.pie.fill")
                    }
                
                Text("Expenses")
                    .tabItem {
                        Label("Expenses", systemImage: "dollarsign.circle.fill")
                    }
                
                Text("Friends")
                    .tabItem {
                        Label("Friends", systemImage: "person.fill")
                    }
                
                DebugView()
                    .tabItem {
                        Label("Debug", systemImage: "ladybug.fill")
                    }
                
                Text("Analytics")
                    .tabItem {
                        Label("Analytics", systemImage: "chart.bar.fill")
                    }
            } else {
                ProgressView()
            }
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 

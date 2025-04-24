import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            if let user = authViewModel.user {
                NavigationStack {
                    DashboardView(userID: user.id)
                }
                .tabItem {
                    Label("Dashboard", systemImage: "chart.pie.fill")
                }
                
                NavigationStack {
                    ExpensesView(userID: user.id)
                }
                .tabItem {
                    Label("Expenses", systemImage: "dollarsign.circle.fill")
                }
                
                NavigationStack {
                    FriendsView(userID: user.id)
                }
                .tabItem {
                    Label("Friends", systemImage: "person.2.fill")
                }
                
                NavigationStack {
                    DebugView()
                }
                .tabItem {
                    Label("Debug", systemImage: "ladybug.fill")
                }
                
                NavigationStack {
//                    AnalyticsView(userID: user.id)
                }
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

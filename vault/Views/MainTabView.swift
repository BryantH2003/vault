import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var databaseService = DatabaseService()
    
    var body: some View {
        TabView {
            DashboardView(databaseService: databaseService, userId: authViewModel.user?.id ?? "")
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
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
} 

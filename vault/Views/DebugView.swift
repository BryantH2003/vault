import SwiftUI

struct DebugView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isLoading = false
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let databaseService = FirebaseService.shared
    private let debugDatabaseService = DebugService.shared
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Database Operations")) {
                    Button(action: clearDatabase) {
                        Label("Clear Database", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                    
                    Button(action: populateDatabase) {
                        Label("Populate with Dummy Data", systemImage: "plus.circle")
                    }
                }
                
                Section(header: Text("Database Statistics")) {
                    NavigationLink(destination: DatabaseStatsView()) {
                        Label("View Database Statistics", systemImage: "chart.bar")
                    }
                }
            }
            .navigationTitle("Debug Tools")
            .alert("Debug Operation", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
            .overlay {
                if isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
    
    private func clearDatabase() {
        isLoading = true
        
        Task {
            do {
                print("Clearing database...")
                try await debugDatabaseService.clearDatabase()
                alertMessage = "Database cleared successfully"
                showingAlert = true
                print("Database cleared successfully")
            } catch {
                print("Error clearing database: \(error.localizedDescription)")
                alertMessage = "Error clearing database: \(error.localizedDescription)"
                showingAlert = true
            }
            
            isLoading = false
        }
    }
    
    private func populateDatabase() {
        isLoading = true
        
        Task {
            do {
                guard let userId = authViewModel.user?.id else {
                    throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
                
                print("Starting database population for user: \(userId)")
                
                // Use DebugService to populate the data
                try await debugDatabaseService.createDummyData(for: userId)
                
                alertMessage = "Database populated successfully with dummy data"
                showingAlert = true
                print("Database populated successfully")
            } catch {
                print("Error populating database: \(error.localizedDescription)")
                alertMessage = "Error populating database: \(error.localizedDescription)"
                showingAlert = true
            }
            
            isLoading = false
        }
    }
}

struct DatabaseStatsView: View {
    @State private var stats: [String: Int] = [:]
    @State private var isLoading = true
    
    private let databaseService = FirebaseService.shared
    
    var body: some View {
        List {
            ForEach(Array(stats.keys.sorted()), id: \.self) { key in
                HStack {
                    Text(key)
                    Spacer()
                    Text("\(stats[key] ?? 0)")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Database Statistics")
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        Task {
            do {
                let users = try await databaseService.getAllUsers()
                let expenses = try await databaseService.getAllExpenses()
                let incomes = try await databaseService.getAllIncomes()
                let categories = try await databaseService.getCategories()
                let budgets = try await databaseService.getAllBudgets()
                let savingsGoals = try await databaseService.getAllSavingsGoals()
                
                stats = [
                    "Users": users.count,
                    "Expenses": expenses.count,
                    "Incomes": incomes.count,
                    "Categories": categories.count,
                    "Budgets": budgets.count,
                    "Savings Goals": savingsGoals.count
                ]
                
                isLoading = false
            } catch {
                print("Error loading stats: \(error)")
                isLoading = false
            }
        }
    }
}

#Preview {
    DebugView()
}

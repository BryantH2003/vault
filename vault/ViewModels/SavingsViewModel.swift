import Foundation
import FirebaseFirestore

class SavingsViewModel: ObservableObject {
    @Published var savings: [Savings] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let databaseService: DatabaseService
    private var selectedDate: Date
    
    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
        self.selectedDate = Date()
    }
    
    func loadSavings(for userId: String) {
        isLoading = true
            error = nil
            
            let calendar = Calendar.current
            let month = calendar.component(.month, from: selectedDate)
            let year = calendar.component(.year, from: selectedDate)
            
            Task {
                do {
                    // Get the savings for the specified month and year
                    if let savings = try await databaseService.getSavings(for: userId, month: month, year: year) {
                        // If savings is not nil, assign it to the savings property
                        await MainActor.run {
                            self.savings = [savings] // Wrap it in an array
                            self.isLoading = false
                        }
                    } else {
                        // Handle the case where no savings were found
                        await MainActor.run {
                            self.savings = [] // Set to an empty array
                            self.isLoading = false
                        }
                    }
                } catch {
                    await MainActor.run {
                        self.error = error
                        self.isLoading = false
                    }
                }
            }
    }
    
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }
    
    func addSavings(_ savings: Savings) {
        Task {
            do {
                try await databaseService.addSavings(savings)
                await MainActor.run {
                    self.savings.append(savings)
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
    
    func updateSavings(_ savings: Savings) {
        Task {
            do {
                try await databaseService.updateSavings(savings)
                await MainActor.run {
                    if let index = self.savings.firstIndex(where: { $0.uniqueKey == savings.uniqueKey }) {
                        self.savings[index] = savings
                    }
                }
            } catch {
                await MainActor.run {
                    self.error = error
                }
            }
        }
    }
} 

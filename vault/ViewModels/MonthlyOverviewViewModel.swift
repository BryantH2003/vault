import Foundation
import FirebaseFirestore

class MonthlyOverviewViewModel: ObservableObject {
    @Published var monthlyOverview: MonthlyOverview?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let databaseService: DatabaseService
    
    init(databaseService: DatabaseService) {
        self.databaseService = databaseService
    }
    
    func loadMonthlyOverview(for userId: String, date: Date) {
        isLoading = true
        error = nil
        
        Task {
            do {
                let (spent, saved, previousSpent, previousSaved) = try await databaseService.getMonthlyOverview(for: userId, date: date)
                let calendar = Calendar.current
                let month = calendar.component(.month, from: date)
                let year = calendar.component(.year, from: date)
                
                let overview = MonthlyOverview(
                    spent: spent,
                    previousSpent: previousSpent,
                    saved: saved,
                    previousSaved: previousSaved,
                    month: month,
                    year: year,
                    userId: userId
                )
                
                await MainActor.run {
                    self.monthlyOverview = overview
                    self.isLoading = false
                }
            } catch {
                await MainActor.run {
                    self.error = error
                    self.isLoading = false
                }
            }
        }
    }
} 
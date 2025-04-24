import Foundation

struct BarData: Identifiable {
    let id = UUID()
    let period: String
    let income: Double
    let expenses: Double
    let savings: Double
}

@MainActor
class AnalyticsViewModel: ObservableObject {
    @Published var chartData: [BarData] = []
    @Published var currentStartDate = Date()
    @Published var isLoading = false
    @Published var error: Error?
    @Published var timeframeOption: TimeframeOption = .monthly
    
    private let expenseService = ExpenseService.shared
    private let incomeService = IncomeService.shared
    private let fixedExpenseService = FixedExpenseService.shared
    
    // Cache structure
    private var cache: [String: [BarData]] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    private var lastCacheUpdate: [String: Date] = [:]
    
    private func cacheKey(forUserID userID: UUID, timeframe: TimeframeOption, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        return "\(userID)-\(timeframe)-\(dateFormatter.string(from: date))"
    }
    
    private func isCacheValid(forKey key: String) -> Bool {
        guard let lastUpdate = lastCacheUpdate[key],
              let cachedData = cache[key],
              !cachedData.isEmpty else {
            return false
        }
        
        return Date().timeIntervalSince(lastUpdate) < cacheTimeout
    }
    
    func loadData(forUserID userID: UUID) async {
        isLoading = true
        error = nil
        
        let cacheKey = cacheKey(forUserID: userID, timeframe: timeframeOption, date: currentStartDate)
        
        if isCacheValid(forKey: cacheKey) {
            chartData = cache[cacheKey] ?? []
            isLoading = false
            return
        }
        
        do {
            let calendar = Calendar.current
            var startDate: Date
            var endDate: Date
            
            if timeframeOption == .monthly {
                startDate = calendar.date(byAdding: .month, value: -11, to: calendar.startOfMonth(for: currentStartDate)) ?? currentStartDate
                endDate = calendar.endOfMonth(for: currentStartDate)
            } else {
                startDate = calendar.date(byAdding: .year, value: -11, to: calendar.startOfYear(for: currentStartDate)) ?? currentStartDate
                endDate = calendar.endOfYear(for: currentStartDate)
            }
            
            var newChartData: [BarData] = []
            var currentDate = startDate
            
            while currentDate <= endDate {
                let periodEndDate = timeframeOption == .monthly 
                    ? calendar.endOfMonth(for: currentDate)
                    : calendar.endOfYear(for: currentDate)
                
                let income = try await loadIncome(forUserID: userID, from: currentDate, to: periodEndDate)
                let (expenses, fixedExpenses) = try await loadExpenses(forUserID: userID, from: currentDate, to: periodEndDate)
                let totalExpenses = expenses + fixedExpenses
                let savings = income - totalExpenses
                
                let periodFormatter = DateFormatter()
                periodFormatter.dateFormat = timeframeOption == .monthly ? "MMM yyyy" : "yyyy"
                let period = periodFormatter.string(from: currentDate)
                
                newChartData.append(BarData(
                    period: period,
                    income: income,
                    expenses: totalExpenses,
                    savings: savings
                ))
                
                // Move to next period
                if timeframeOption == .monthly {
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                } else {
                    currentDate = calendar.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
                }
            }
            
            // Update cache
            cache[cacheKey] = newChartData
            lastCacheUpdate[cacheKey] = Date()
            
            chartData = newChartData
            isLoading = false
            
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func loadIncome(forUserID userID: UUID, from startDate: Date, to endDate: Date) async throws -> Double {
        let incomes = try await incomeService.getIncomes(forUserID: userID, in: startDate...endDate)
        return incomes.reduce(0) { $0 + $1.amount }
    }
    
    private func loadExpenses(forUserID userID: UUID, from startDate: Date, to endDate: Date) async throws -> (expenses: Double, fixedExpenses: Double) {
        let expenses = try await expenseService.getExpensesInDateRange(forUserID: userID, in: startDate...endDate)
        let fixedExpenses = try await fixedExpenseService.getFixedExpensesDateRange(forUserID: userID, in: startDate...endDate)
        
        return (
            expenses: expenses.reduce(0) { $0 + $1.amount },
            fixedExpenses: fixedExpenses.reduce(0) { $0 + $1.amount }
        )
    }
    
    func nextTimeframe() {
        let calendar = Calendar.current
        if timeframeOption == .monthly {
            currentStartDate = calendar.date(byAdding: .month, value: 1, to: currentStartDate) ?? currentStartDate
        } else {
            currentStartDate = calendar.date(byAdding: .year, value: 1, to: currentStartDate) ?? currentStartDate
        }
    }
    
    func previousTimeframe() {
        let calendar = Calendar.current
        if timeframeOption == .monthly {
            currentStartDate = calendar.date(byAdding: .month, value: -1, to: currentStartDate) ?? currentStartDate
        } else {
            currentStartDate = calendar.date(byAdding: .year, value: -1, to: currentStartDate) ?? currentStartDate
        }
    }
}

// MARK: - Calendar Extensions
extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
    
    func endOfMonth(for date: Date) -> Date {
        guard let startOfNextMonth = self.date(byAdding: DateComponents(month: 1), to: startOfMonth(for: date)) else {
            return date
        }
        return self.date(byAdding: .day, value: -1, to: startOfNextMonth) ?? date
    }
    
    func startOfYear(for date: Date) -> Date {
        var components = dateComponents([.year], from: date)
        components.month = 1
        components.day = 1
        return self.date(from: components) ?? date
    }
    
    func endOfYear(for date: Date) -> Date {
        var components = dateComponents([.year], from: date)
        components.month = 12
        components.day = 31
        return self.date(from: components) ?? date
    }
} 
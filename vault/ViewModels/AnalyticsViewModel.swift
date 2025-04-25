import Foundation

struct BarData: Identifiable {
    let id = UUID()
    let period: String
    let income: Double
    let expenses: Double
    let savings: Double
    let date: Date // Adding date for sorting and window management
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
    private var cache: [String: BarData] = [:]
    private let cacheTimeout: TimeInterval = 300 // 5 minutes
    private var lastCacheUpdate: [String: Date] = [:]
    
    // Window management
    private let displayWindow = 4 // Number of periods to display
    private let preloadWindow = 1 // Number of periods to preload on each side
    
    private func cacheKey(forUserID userID: UUID, date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = timeframeOption == .monthly ? "yyyy-MM" : "yyyy"
        return "\(userID)-\(dateFormatter.string(from: date))"
    }
    
    private func isCacheValid(forKey key: String) -> Bool {
        guard let lastUpdate = lastCacheUpdate[key] else { return false }
        return Date().timeIntervalSince(lastUpdate) < cacheTimeout
    }
    
    func loadData(forUserID userID: UUID) async {
        isLoading = true
        error = nil
        
        do {
            let calendar = Calendar.current
            var startDate = currentStartDate
            
            // Calculate the window range
            let totalWindowSize = displayWindow + (2 * preloadWindow)
            let windowStartOffset = -(preloadWindow + displayWindow - 1)
            
            if timeframeOption == .monthly {
                startDate = calendar.date(byAdding: .month, value: windowStartOffset, to: calendar.startOfMonth(for: currentStartDate)) ?? currentStartDate
            } else {
                startDate = calendar.date(byAdding: .year, value: windowStartOffset, to: calendar.startOfYear(for: currentStartDate)) ?? currentStartDate
            }
            
            var newChartData: [BarData] = []
            var currentDate = startDate
            
            // Load data for the window plus preload periods
            for _ in 0..<totalWindowSize {
                let periodKey = cacheKey(forUserID: userID, date: currentDate)
                
                let barData: BarData
                if isCacheValid(forKey: periodKey), let cachedData = cache[periodKey] {
                    barData = cachedData
                } else {
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
                    
                    barData = BarData(
                        period: period,
                        income: income,
                        expenses: totalExpenses,
                        savings: savings,
                        date: currentDate
                    )
                    
                    // Update cache
                    cache[periodKey] = barData
                    lastCacheUpdate[periodKey] = Date()
                }
                
                newChartData.append(barData)
                
                // Move to next period
                if timeframeOption == .monthly {
                    currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate) ?? currentDate
                } else {
                    currentDate = calendar.date(byAdding: .year, value: 1, to: currentDate) ?? currentDate
                }
            }
            
            // Clean up old cache entries
            cleanCache()
            
            // Update the chart with the display window (excluding preload data)
            chartData = Array(newChartData.dropFirst(preloadWindow).prefix(displayWindow))
            isLoading = false
            
        } catch {
            self.error = error
            isLoading = false
        }
    }
    
    private func cleanCache() {
        let now = Date()
        let expiredKeys = lastCacheUpdate.filter { now.timeIntervalSince($0.value) > cacheTimeout }.keys
        expiredKeys.forEach { key in
            cache.removeValue(forKey: key)
            lastCacheUpdate.removeValue(forKey: key)
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
import Foundation

extension Date {
    static func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    static func allMonths() -> [Date] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: Date())
        let currentMonth = calendar.component(.month, from: Date())
        
        // Generate dates for the last 12 months and next 12 months
        var dates: [Date] = []
        
        // Start from 12 months ago
        var components = DateComponents()
        components.year = currentYear
        components.month = currentMonth
        components.day = 1
        
        if let currentDate = calendar.date(from: components) {
            // Add past 12 months
            for i in -12...12 {
                if let date = calendar.date(byAdding: .month, value: i, to: currentDate) {
                    dates.append(date)
                }
            }
        }
        
        return dates.sorted(by: { $0 > $1 })
    }
    
    func startOfMonth() -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    func endOfMonth() -> Date {
        let calendar = Calendar.current
        if let start = calendar.date(from: calendar.dateComponents([.year, .month], from: self)),
           let end = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: start) {
            return end
        }
        return self
    }
    
    var previousMonth: Date {
        let calendar = Calendar.current
        let components = DateComponents(month: -1)
        return calendar.date(byAdding: components, to: self) ?? self
    }
} 
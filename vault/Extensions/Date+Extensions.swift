import Foundation

extension Date {
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    var endOfMonth: Date {
        let calendar = Calendar.current
        let components = DateComponents(month: 1, day: -1)
        return calendar.date(byAdding: components, to: startOfMonth) ?? self
    }
    
    var previousMonth: Date {
        let calendar = Calendar.current
        let components = DateComponents(month: -1)
        return calendar.date(byAdding: components, to: self) ?? self
    }
} 
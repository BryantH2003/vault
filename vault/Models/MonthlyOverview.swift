import Foundation

struct MonthlyOverview: Identifiable, Codable {
    let id: UUID
    let userID: UUID
    let year: Int
    let month: Int
    let totalIncome: Double
    let totalExpenses: Double
    let netSavings: Double
    
    var uniqueKey: String {
        "\(userID)_\(year)_\(month)"
    }
    
    init(id: UUID = UUID(),
        userID: UUID = UUID(),
        year: Int,
        month: Int,
        totalIncome: Double,
        totalExpenses: Double,
        netSavings: Double
        ) {
        self.id = id
        self.userID = userID
        self.year = year
        self.month = month
        self.totalIncome = totalIncome
        self.totalExpenses = totalExpenses
        self.netSavings = netSavings
        
        
    }
}

// MARK: - Firestore Conversion
extension MonthlyOverview {
    init?(from dictionary: [String: Any], id: UUID) {
        guard
            let userIdString = dictionary["userId"] as? String,
            let userID = UUID(uuidString: userIdString),
            let year = dictionary["year"] as? Int,
            let month = dictionary["month"] as? Int,
            let totalIncome = dictionary["totalIncome"] as? Double,
            let totalExpenses = dictionary["totalExpenses"] as? Double,
            let netSavings = dictionary["netSavings"] as? Double
        else {
            return nil
        }
        
        self.init(
            id: id,
            userID: userID,
            year: year,
            month: month,
            totalIncome: totalIncome,
            totalExpenses: totalExpenses,
            netSavings: netSavings
        )
    }
    
    var asDictionary: [String: Any] {
        [
            "userID": userID,
            "year": year,
            "month": month,
            "totalIncome": totalIncome,
            "totalExpenses": totalExpenses,
            "netSavings": netSavings,
        ]
    }
} 

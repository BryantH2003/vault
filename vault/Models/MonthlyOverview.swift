import Foundation

struct MonthlyOverview: Identifiable, Codable {
    let id: String
    let spent: Double
    let previousSpent: Double
    let saved: Double
    let previousSaved: Double
    let month: Int
    let year: Int
    let userId: String
    
    var uniqueKey: String {
        "\(userId)_\(year)_\(month)"
    }
    
    init(id: String = UUID().uuidString,
         spent: Double,
         previousSpent: Double,
         saved: Double,
         previousSaved: Double,
         month: Int,
         year: Int,
         userId: String) {
        self.id = id
        self.spent = spent
        self.previousSpent = previousSpent
        self.saved = saved
        self.previousSaved = previousSaved
        self.month = month
        self.year = year
        self.userId = userId
    }
}

// MARK: - Firestore Conversion
extension MonthlyOverview {
    init?(from dictionary: [String: Any], id: String) {
        guard
            let spent = dictionary["spent"] as? Double,
            let previousSpent = dictionary["previousSpent"] as? Double,
            let saved = dictionary["saved"] as? Double,
            let previousSaved = dictionary["previousSaved"] as? Double,
            let month = dictionary["month"] as? Int,
            let year = dictionary["year"] as? Int,
            let userId = dictionary["userId"] as? String
        else {
            return nil
        }
        
        self.init(
            id: id,
            spent: spent,
            previousSpent: previousSpent,
            saved: saved,
            previousSaved: previousSaved,
            month: month,
            year: year,
            userId: userId
        )
    }
    
    var asDictionary: [String: Any] {
        [
            "spent": spent,
            "previousSpent": previousSpent,
            "saved": saved,
            "previousSaved": previousSaved,
            "month": month,
            "year": year,
            "userId": userId
        ]
    }
} 
import Foundation

/// Represents an expense category in the application
struct Category: Identifiable, Codable {
    let id: UUID
    var categoryName: String
    var fixedExpense: Bool
    
    init(id: UUID = UUID(),
         categoryName: String,
         fixedExpense: Bool = false) {
        self.id = id
        self.categoryName = categoryName
        self.fixedExpense = fixedExpense
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case categoryName
        case fixedExpense
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode UUID from string
        if let idString = try? container.decode(String.self, forKey: .id) {
            self.id = UUID(uuidString: idString) ?? UUID()
        } else {
            self.id = try container.decode(UUID.self, forKey: .id)
        }
        
        self.categoryName = try container.decode(String.self, forKey: .categoryName)
        self.fixedExpense = try container.decode(Bool.self, forKey: .fixedExpense)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode UUID as string
        try container.encode(id.uuidString, forKey: .id)
        try container.encode(categoryName, forKey: .categoryName)
        try container.encode(fixedExpense, forKey: .fixedExpense)
    }
} 
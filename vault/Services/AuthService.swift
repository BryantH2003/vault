import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
    private init() {}
    
    func getCurrentUserID() throws -> UUID {
        guard let user = Auth.auth().currentUser else {
            throw ServiceError.userNotFound
        }
        return UUID(uuidString: user.uid) ?? UUID()
    }
}

enum ServiceError: LocalizedError {
    case userNotFound
    case invalidData
    case networkError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        case .invalidData:
            return "Invalid data"
        case .networkError:
            return "Network error"
        case .unknown:
            return "Unknown error"
        }
    }
} 
import Foundation
import CoreData

/// Service for managing User entities
class UserService: BaseCoreDataService<UserEntity, User> {
    static let shared = UserService(container: CoreDataService.shared.container, entityName: "UserEntity")
    
    override func mapModelToEntity(_ model: User, _ entity: UserEntity) async throws {
        entity.id = model.id
        entity.username = model.username
        entity.email = model.email
        entity.passwordHash = model.passwordHash
        entity.fullName = model.fullName
        entity.registrationDate = model.registrationDate
        entity.employmentStatus = model.employmentStatus
        entity.netPaycheckIncome = model.netPaycheckIncome
        entity.profileImageUrl = model.profileImageUrl
        entity.monthlyIncome = model.monthlyIncome
        entity.monthlySavingsGoal = model.monthlySavingsGoal
        entity.monthlySpendingLimit = model.monthlySpendingLimit
        entity.friends = model.friends
        entity.createdAt = model.createdAt
        entity.updatedAt = model.updatedAt
    }
    
    override func mapEntityToModel(_ entity: UserEntity) async throws -> User {
        guard let id = entity.id,
              let username = entity.username,
              let email = entity.email,
              let passwordHash = entity.passwordHash,
              let registrationDate = entity.registrationDate,
              let employmentStatus = entity.employmentStatus,
              let friends = entity.friends as? [String],
              let createdAt = entity.createdAt,
              let updatedAt = entity.updatedAt else {
            throw NSError(domain: "UserService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return User(
            id: id,
            username: username,
            email: email,
            passwordHash: passwordHash,
            fullName: entity.fullName,
            registrationDate: registrationDate,
            employmentStatus: employmentStatus,
            netPaycheckIncome: entity.netPaycheckIncome,
            profileImageUrl: entity.profileImageUrl,
            monthlyIncome: entity.monthlyIncome,
            monthlySavingsGoal: entity.monthlySavingsGoal,
            monthlySpendingLimit: entity.monthlySpendingLimit,
            friends: friends,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    /// Get all users
    func getAllUsers() async throws -> [User] {
        return try await getAll()
    }
    
    /// Get user by email
    func getByEmail(_ email: String) async throws -> User? {
        let predicate = NSPredicate(format: "email == %@", email)
        let users = try await getAllWithPredicate(predicate)
        return users.first
    }
    
    /// Get user by username
    func getByUsername(_ username: String) async throws -> User? {
        let predicate = NSPredicate(format: "username == %@", username)
        let users = try await getAllWithPredicate(predicate)
        return users.first
    }
    
    // MARK: - User Operations
    func createUser(_ user: User) async throws -> User {
        let context = container.viewContext
        let userEntity = UserEntity(context: context)
        userEntity.id = user.id
        userEntity.username = user.username
        userEntity.email = user.email
        userEntity.passwordHash = user.passwordHash
        userEntity.fullName = user.fullName
        userEntity.registrationDate = user.registrationDate
        userEntity.employmentStatus = user.employmentStatus
        userEntity.netPaycheckIncome = user.netPaycheckIncome
        userEntity.profileImageUrl = user.profileImageUrl
        userEntity.monthlyIncome = user.monthlyIncome
        userEntity.monthlySavingsGoal = user.monthlySavingsGoal
        userEntity.monthlySpendingLimit = user.monthlySpendingLimit
        userEntity.friends = user.friends
        userEntity.createdAt = user.createdAt
        userEntity.updatedAt = user.updatedAt
        
        try context.save()
        return user
    }
    
    func getUser(id: UUID) async throws -> User? {
        let context = container.viewContext
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let userEntity = result.first else { return nil }
        
        return try await mapEntityToModel(userEntity)
    }
    
    func updateUser(_ user: User) async throws -> User {
        let context = container.viewContext
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "id == %@", user.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let userEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        try await mapModelToEntity(user, userEntity)
        try context.save()
        return user
    }
    
    func deleteUser(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<UserEntity>(entityName: "UserEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let userEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])
        }
        
        context.delete(userEntity)
        try context.save()
    }
}

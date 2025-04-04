import Foundation
import CoreData

/// Service for managing SavingsGoal entities
class SavingsGoalService: BaseCoreDataService<SavingsGoalEntity, SavingsGoal> {
    static let shared = SavingsGoalService(container: CoreDataService.shared.container, entityName: "SavingsGoalEntity")
    
    override func mapModelToEntity(_ model: SavingsGoal, _ entity: SavingsGoalEntity) async throws {
        entity.id = model.id
        entity.userID = model.userID
        entity.goalName = model.goalName
        entity.targetAmount = model.targetAmount
        entity.currentAmount = model.currentAmount
        entity.targetDate = model.targetDate
        entity.creationDate = model.creationDate
    }
    
    override func mapEntityToModel(_ entity: SavingsGoalEntity) async throws -> SavingsGoal {
        guard let id = entity.id,
              let userID = entity.userID,
              let goalName = entity.goalName,
              let creationDate = entity.creationDate else {
            throw NSError(domain: "SavingsGoalService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return SavingsGoal(
            id: id,
            userID: userID,
            goalName: goalName,
            targetAmount: entity.targetAmount,
            currentAmount: entity.currentAmount,
            targetDate: entity.targetDate,
            creationDate: creationDate
        )
    }
    
    /// Get savings goals for a user
    func getForUser(_ userID: UUID) async throws -> [SavingsGoal] {
        let predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get active savings goals for a user
    func getActiveForUser(_ userID: UUID) async throws -> [SavingsGoal] {
        let predicate = NSPredicate(format: "userID == %@ AND targetDate >= %@", 
                                  userID as CVarArg,
                                  Date() as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Update the current amount of a savings goal
    func updateCurrentAmount(_ id: UUID, amount: Double) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<SavingsGoalEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first else {
            throw NSError(domain: "SavingsGoalService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Savings goal not found"])
        }
        
        entity.currentAmount = amount
        try context.save()
    }
    
    // MARK: - Savings Goal Operations
    func createSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal {
        let context = container.viewContext
        let savingsGoalEntity = SavingsGoalEntity(context: context)
        savingsGoalEntity.id = savingsGoal.id
        savingsGoalEntity.userID = savingsGoal.userID
        savingsGoalEntity.goalName = savingsGoal.goalName
        savingsGoalEntity.targetAmount = savingsGoal.targetAmount
        savingsGoalEntity.currentAmount = savingsGoal.currentAmount
        savingsGoalEntity.targetDate = savingsGoal.targetDate
        savingsGoalEntity.creationDate = savingsGoal.creationDate
        
        try context.save()
        return savingsGoal
    }
    
    func getSavingsGoal(id: UUID) async throws -> SavingsGoal? {
        let context = container.viewContext
        let request = NSFetchRequest<SavingsGoalEntity>(entityName: "SavingsGoalEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let savingsGoalEntity = result.first else { return nil }
        
        return try await mapEntityToModel(savingsGoalEntity)
    }
    
    func getSavingsGoals(forUserID: UUID) async throws -> [SavingsGoal] {
        let context = container.viewContext
        let request = NSFetchRequest<SavingsGoalEntity>(entityName: "SavingsGoalEntity")
        request.predicate = NSPredicate(format: "userID == %@", forUserID as CVarArg)
        
        let result = try context.fetch(request)
        var goals: [SavingsGoal] = []
        for entity in result {
            if let goal = try? await mapEntityToModel(entity) {
                goals.append(goal)
            }
        }
        return goals
    }
    
    func updateSavingsGoal(_ savingsGoal: SavingsGoal) async throws -> SavingsGoal {
        let context = container.viewContext
        let request = NSFetchRequest<SavingsGoalEntity>(entityName: "SavingsGoalEntity")
        request.predicate = NSPredicate(format: "id == %@", savingsGoal.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let savingsGoalEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Savings Goal not found"])
        }
        
        savingsGoalEntity.userID = savingsGoal.userID
        savingsGoalEntity.goalName = savingsGoal.goalName
        savingsGoalEntity.targetAmount = savingsGoal.targetAmount
        savingsGoalEntity.currentAmount = savingsGoal.currentAmount
        savingsGoalEntity.targetDate = savingsGoal.targetDate
        
        try context.save()
        return savingsGoal
    }
    
    func deleteSavingsGoal(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<SavingsGoalEntity>(entityName: "SavingsGoalEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let savingsGoalEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Savings Goal not found"])
        }
        
        context.delete(savingsGoalEntity)
        try context.save()
    }
}

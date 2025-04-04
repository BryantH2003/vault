import Foundation
import CoreData

/// Service for managing Budget entities
class BudgetService: BaseCoreDataService<BudgetEntity, Budget> {
    static let shared = BudgetService(container: CoreDataService.shared.container, entityName: "BudgetEntity")
    
    override func mapModelToEntity(_ model: Budget, _ entity: BudgetEntity) async throws {
        entity.id = model.id
        entity.userID = model.userID
        entity.categoryID = model.categoryID
        entity.title = model.title
        entity.budgetAmount = model.budgetAmount
        entity.startDate = model.startDate
        entity.endDate = model.endDate
    }
    
    override func mapEntityToModel(_ entity: BudgetEntity) async throws -> Budget {
        guard let id = entity.id,
              let userID = entity.userID,
              let categoryID = entity.categoryID,
              let title = entity.title,
              let startDate = entity.startDate,
              let endDate = entity.endDate else {
            throw NSError(domain: "BudgetService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return Budget(
            id: id,
            userID: userID,
            categoryID: categoryID,
            title: title,
            budgetAmount: entity.budgetAmount,
            startDate: startDate,
            endDate: endDate
        )
    }
    
    /// Get budgets for a user
    func getForUser(_ userID: UUID) async throws -> [Budget] {
        let predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get budgets for a category
    func getForCategory(_ categoryID: UUID) async throws -> [Budget] {
        let predicate = NSPredicate(format: "categoryID == %@", categoryID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get active budgets for a user
    func getActiveForUser(_ userID: UUID) async throws -> [Budget] {
        let now = Date()
        let predicate = NSPredicate(format: "userID == %@ AND startDate <= %@ AND endDate >= %@",
                                  userID as CVarArg,
                                  now as CVarArg,
                                  now as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get budgets for a user in a date range
    func getForUser(_ userID: UUID, in dateRange: ClosedRange<Date>) async throws -> [Budget] {
        let predicate = NSPredicate(format: "userID == %@ AND startDate <= %@ AND endDate >= %@",
                                  userID as CVarArg,
                                  dateRange.upperBound as CVarArg,
                                  dateRange.lowerBound as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    // MARK: - Budget Operations
    func createBudget(_ budget: Budget) async throws -> Budget {
        let context = container.viewContext
        let budgetEntity = BudgetEntity(context: context)
        budgetEntity.id = budget.id
        budgetEntity.userID = budget.userID
        budgetEntity.categoryID = budget.categoryID
        budgetEntity.title = budget.title
        budgetEntity.budgetAmount = budget.budgetAmount
        budgetEntity.startDate = budget.startDate
        budgetEntity.endDate = budget.endDate
        
        try context.save()
        return budget
    }
    
    func getBudget(id: UUID) async throws -> Budget? {
        let context = container.viewContext
        let request = NSFetchRequest<BudgetEntity>(entityName: "BudgetEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let budgetEntity = result.first else { return nil }
        
        return try await mapEntityToModel(budgetEntity)
    }
    
    func getBudgets(forUserID: UUID) async throws -> [Budget] {
        let context = container.viewContext
        let request = NSFetchRequest<BudgetEntity>(entityName: "BudgetEntity")
        request.predicate = NSPredicate(format: "userID == %@", forUserID as CVarArg)
        
        let result = try context.fetch(request)
        var budgets: [Budget] = []
        for entity in result {
            if let budget = try? await mapEntityToModel(entity) {
                budgets.append(budget)
            }
        }
        return budgets
    }
    
    func updateBudget(_ budget: Budget) async throws -> Budget {
        let context = container.viewContext
        let request = NSFetchRequest<BudgetEntity>(entityName: "BudgetEntity")
        request.predicate = NSPredicate(format: "id == %@", budget.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let budgetEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Budget not found"])
        }
        
        budgetEntity.userID = budget.userID
        budgetEntity.categoryID = budget.categoryID
        budgetEntity.title = budget.title
        budgetEntity.budgetAmount = budget.budgetAmount
        budgetEntity.startDate = budget.startDate
        budgetEntity.endDate = budget.endDate
        
        try context.save()
        return budget
    }
    
    func deleteBudget(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<BudgetEntity>(entityName: "BudgetEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let budgetEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Budget not found"])
        }
        
        context.delete(budgetEntity)
        try context.save()
    }
}

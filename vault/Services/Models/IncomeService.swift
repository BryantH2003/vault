import Foundation
import CoreData

/// Service for managing Income entities
class IncomeService: BaseCoreDataService<IncomeEntity, Income> {
    static let shared = IncomeService(container: CoreDataService.shared.container, entityName: "IncomeEntity")
    
    override func mapModelToEntity(_ model: Income, _ entity: IncomeEntity) async throws {
        entity.id = model.id
        entity.userID = model.userID
        entity.source = model.source
        entity.incomeDescription = model.description
        entity.amount = model.amount
        entity.transactionDate = model.transactionDate
    }
    
    override func mapEntityToModel(_ entity: IncomeEntity) async throws -> Income {
        guard let id = entity.id,
              let userID = entity.userID,
              let source = entity.source,
              let description = entity.incomeDescription,
              let transactionDate = entity.transactionDate else {
            throw NSError(domain: "IncomeService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return Income(
            id: id,
            userID: userID,
            source: source,
            description: description,
            amount: entity.amount,
            transactionDate: transactionDate
        )
    }
    
    /// Get incomes for a user
    func getForUser(_ userID: UUID) async throws -> [Income] {
        let predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get incomes for a user in a date range
    func getForUser(_ userID: UUID, in dateRange: ClosedRange<Date>) async throws -> [Income] {
        let predicate = NSPredicate(format: "userID == %@ AND transactionDate >= %@ AND transactionDate <= %@",
                                  userID as CVarArg,
                                  dateRange.lowerBound as CVarArg,
                                  dateRange.upperBound as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get total income for a user in a date range
    func getTotalForUser(_ userID: UUID, in dateRange: ClosedRange<Date>) async throws -> Double {
        let incomes = try await getForUser(userID, in: dateRange)
        return incomes.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Income Operations
    func createIncome(_ income: Income) async throws -> Income {
        let context = container.viewContext
        let incomeEntity = IncomeEntity(context: context)
        incomeEntity.id = income.id
        incomeEntity.userID = income.userID
        incomeEntity.source = income.source
        incomeEntity.incomeDescription = income.description
        incomeEntity.amount = income.amount
        incomeEntity.transactionDate = income.transactionDate
        
        try context.save()
        return income
    }
    
    func getIncome(id: UUID) async throws -> Income? {
        let context = container.viewContext
        let request = NSFetchRequest<IncomeEntity>(entityName: "IncomeEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let incomeEntity = result.first else { return nil }
        
        return try await mapEntityToModel(incomeEntity)
    }
    
    func getIncomes(forUserID: UUID) async throws -> [Income] {
        let context = container.viewContext
        let request = NSFetchRequest<IncomeEntity>(entityName: "IncomeEntity")
        request.predicate = NSPredicate(format: "userID == %@", forUserID as CVarArg)
        
        let result = try context.fetch(request)
        var incomes: [Income] = []
        for entity in result {
            if let income = try? await mapEntityToModel(entity) {
                incomes.append(income)
            }
        }
        return incomes
    }
    
    func updateIncome(_ income: Income) async throws -> Income {
        let context = container.viewContext
        let request = NSFetchRequest<IncomeEntity>(entityName: "IncomeEntity")
        request.predicate = NSPredicate(format: "id == %@", income.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let incomeEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Income not found"])
        }
        
        incomeEntity.userID = income.userID
        incomeEntity.source = income.source
        incomeEntity.incomeDescription = income.description
        incomeEntity.amount = income.amount
        incomeEntity.transactionDate = income.transactionDate
        
        try context.save()
        return income
    }
    
    func deleteIncome(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<IncomeEntity>(entityName: "IncomeEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let incomeEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Income not found"])
        }
        
        context.delete(incomeEntity)
        try context.save()
    }
}

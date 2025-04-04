import Foundation
import CoreData

/// Service for managing Expense entities
class ExpenseService: BaseCoreDataService<ExpenseEntity, Expense> {
    static let shared = ExpenseService(container: CoreDataService.shared.container, entityName: "ExpenseEntity")
    
    override func mapModelToEntity(_ model: Expense, _ entity: ExpenseEntity) async throws {
        entity.id = model.id
        entity.userID = model.userID
        entity.categoryID = model.categoryID
        entity.title = model.title
        entity.amount = model.amount
        entity.transactionDate = model.transactionDate
        entity.vendor = model.vendor
    }
    
    override func mapEntityToModel(_ entity: ExpenseEntity) async throws -> Expense {
        guard let id = entity.id,
              let userID = entity.userID,
              let categoryID = entity.categoryID,
              let title = entity.title,
              let transactionDate = entity.transactionDate,
              let vendor = entity.vendor else {
            throw NSError(domain: "ExpenseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return Expense(
            id: id,
            userID: userID,
            categoryID: categoryID,
            title: title,
            amount: entity.amount,
            transactionDate: transactionDate,
            vendor: vendor
        )
    }
    
    /// Get expenses for a user
    func getForUser(_ userID: UUID) async throws -> [Expense] {
        let predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get expenses for a user in a date range
    func getForUser(_ userID: UUID, in dateRange: ClosedRange<Date>) async throws -> [Expense] {
        let predicate = NSPredicate(format: "userID == %@ AND transactionDate >= %@ AND transactionDate <= %@",
                                  userID as CVarArg,
                                  dateRange.lowerBound as CVarArg,
                                  dateRange.upperBound as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get expenses for a category
    func getForCategory(_ categoryID: UUID) async throws -> [Expense] {
        let predicate = NSPredicate(format: "categoryID == %@", categoryID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get expenses for a user and category
    func getForUserAndCategory(_ userID: UUID, _ categoryID: UUID) async throws -> [Expense] {
        let predicate = NSPredicate(format: "userID == %@ AND categoryID == %@",
                                  userID as CVarArg,
                                  categoryID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get expenses for a user and category in a date range
    func getForUserAndCategory(_ userID: UUID, _ categoryID: UUID, in dateRange: ClosedRange<Date>) async throws -> [Expense] {
        let predicate = NSPredicate(format: "userID == %@ AND categoryID == %@ AND transactionDate >= %@ AND transactionDate <= %@",
                                  userID as CVarArg,
                                  categoryID as CVarArg,
                                  dateRange.lowerBound as CVarArg,
                                  dateRange.upperBound as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    /// Get total expenses for a user in a date range
    func getTotalForUser(_ userID: UUID, in dateRange: ClosedRange<Date>) async throws -> Double {
        let expenses = try await getForUser(userID, in: dateRange)
        return expenses.reduce(0) { $0 + $1.amount }
    }
    
    // MARK: - Expense Operations
    func createExpense(_ expense: Expense) async throws -> Expense {
        let context = container.viewContext
        let expenseEntity = ExpenseEntity(context: context)
        expenseEntity.id = expense.id
        expenseEntity.userID = expense.userID
        expenseEntity.categoryID = expense.categoryID
        expenseEntity.title = expense.title
        expenseEntity.amount = expense.amount
        expenseEntity.transactionDate = expense.transactionDate
        expenseEntity.vendor = expense.vendor
        
        try context.save()
        return expense
    }
    
    func getExpense(id: UUID) async throws -> Expense? {
        let context = container.viewContext
        let request = NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let expenseEntity = result.first else { return nil }
        
        return Expense(
            id: expenseEntity.id ?? UUID(),
            userID: expenseEntity.userID ?? UUID(),
            categoryID: expenseEntity.categoryID ?? UUID(),
            title: expenseEntity.title ?? "",
            amount: expenseEntity.amount,
            transactionDate: expenseEntity.transactionDate ?? Date(),
            vendor: expenseEntity.vendor ?? ""
        )
    }
    
    func getExpenses(forUserID: UUID) async throws -> [Expense] {
        let context = container.viewContext
        let request = NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
        request.predicate = NSPredicate(format: "userID == %@", forUserID as CVarArg)
        
        let result = try context.fetch(request)
        return result.compactMap { entity in
            guard let id = entity.id,
                  let userID = entity.userID,
                  let categoryID = entity.categoryID,
                  let title = entity.title,
                  let transactionDate = entity.transactionDate,
                  let vendor = entity.vendor else { return nil }
            
            return Expense(
                id: id,
                userID: userID,
                categoryID: categoryID,
                title: title,
                amount: entity.amount,
                transactionDate: transactionDate,
                vendor: vendor
            )
        }
    }
    
    func updateExpense(_ expense: Expense) async throws -> Expense {
        let context = container.viewContext
        let request = NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", expense.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let expenseEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Expense not found"])
        }
        
        expenseEntity.userID = expense.userID
        expenseEntity.categoryID = expense.categoryID
        expenseEntity.title = expense.title
        expenseEntity.amount = expense.amount
        expenseEntity.transactionDate = expense.transactionDate
        expenseEntity.vendor = expense.vendor
        
        try context.save()
        return expense
    }
    
    func deleteExpense(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<ExpenseEntity>(entityName: "ExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let expenseEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Expense not found"])
        }
        
        context.delete(expenseEntity)
        try context.save()
    }
    
    // MARK: - Fixed Expense Operations
    func createFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense {
        let context = container.viewContext
        let fixedExpenseEntity = FixedExpenseEntity(context: context)
        fixedExpenseEntity.id = fixedExpense.id
        fixedExpenseEntity.userID = fixedExpense.userID
        fixedExpenseEntity.categoryID = fixedExpense.categoryID
        fixedExpenseEntity.title = fixedExpense.title
        fixedExpenseEntity.amount = fixedExpense.amount
        fixedExpenseEntity.dueDate = fixedExpense.dueDate
        fixedExpenseEntity.transactionDate = fixedExpense.transactionDate
        
        try context.save()
        return fixedExpense
    }
    
    func getFixedExpense(id: UUID) async throws -> FixedExpense? {
        let context = container.viewContext
        let request = NSFetchRequest<FixedExpenseEntity>(entityName: "FixedExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first,
              let id = entity.id,
              let userID = entity.userID,
              let categoryID = entity.categoryID,
              let title = entity.title,
              let dueDate = entity.dueDate,
              let transactionDate = entity.transactionDate else { return nil }
        
        return FixedExpense(
            id: id,
            userID: userID,
            categoryID: categoryID,
            title: title,
            amount: entity.amount,
            dueDate: dueDate,
            transactionDate: transactionDate
        )
    }
    
    func getFixedExpenses(forUserID: UUID) async throws -> [FixedExpense] {
        let context = container.viewContext
        let request = NSFetchRequest<FixedExpenseEntity>(entityName: "FixedExpenseEntity")
        request.predicate = NSPredicate(format: "userID == %@", forUserID as CVarArg)
        
        let result = try context.fetch(request)
        var fixedExpenses: [FixedExpense] = []
        
        for entity in result {
            if let id = entity.id,
               let userID = entity.userID,
               let categoryID = entity.categoryID,
               let title = entity.title,
               let dueDate = entity.dueDate,
               let transactionDate = entity.transactionDate {
                
                let fixedExpense = FixedExpense(
                    id: id,
                    userID: userID,
                    categoryID: categoryID,
                    title: title,
                    amount: entity.amount,
                    dueDate: dueDate,
                    transactionDate: transactionDate
                )
                fixedExpenses.append(fixedExpense)
            }
        }
        
        return fixedExpenses
    }
    
    func updateFixedExpense(_ fixedExpense: FixedExpense) async throws -> FixedExpense {
        let context = container.viewContext
        let request = NSFetchRequest<FixedExpenseEntity>(entityName: "FixedExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", fixedExpense.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Fixed Expense not found"])
        }
        
        entity.userID = fixedExpense.userID
        entity.categoryID = fixedExpense.categoryID
        entity.title = fixedExpense.title
        entity.amount = fixedExpense.amount
        entity.dueDate = fixedExpense.dueDate
        entity.transactionDate = fixedExpense.transactionDate
        
        try context.save()
        return fixedExpense
    }
    
    func deleteFixedExpense(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<FixedExpenseEntity>(entityName: "FixedExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Fixed Expense not found"])
        }
        
        context.delete(entity)
        try context.save()
    }
}

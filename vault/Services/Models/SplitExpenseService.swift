//
//  SplitExpenseService.swift
//  vault
//
//  Created by Bryant Huynh on 4/3/25.
//

import Foundation
import CoreData

/// Service for managing Split Expense entities
class SplitExpenseService: BaseCoreDataService<SplitExpenseEntity, SplitExpense> {
    static let shared = SplitExpenseService(container: CoreDataService.shared.container, entityName: "SplitExpenseEntity")
    
    override func mapModelToEntity(_ model: SplitExpense, _ entity: SplitExpenseEntity) async throws {
        entity.id = model.id
        entity.expenseDescription = model.expenseDescription
        entity.totalAmount = model.totalAmount
        entity.payerID = model.payerID
        entity.creationDate = model.creationDate
    }
    
    override func mapEntityToModel(_ entity: SplitExpenseEntity) async throws -> SplitExpense {
        guard let id = entity.id,
              let payerID = entity.payerID,
              let creationDate = entity.creationDate else {
            throw NSError(domain: "SplitExpenseService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return SplitExpense(
            id: id,
            expenseDescription: entity.expenseDescription,
            totalAmount: entity.totalAmount,
            payerID: payerID,
            creationDate: creationDate
        )
    }
    
    /// Get split expenses for a user
    func getForUser(_ userID: UUID) async throws -> [SplitExpense] {
        let predicate = NSPredicate(format: "payerID == %@", userID as CVarArg)
        return try await getAllWithPredicate(predicate)
    }
    
    // MARK: - Split Expense Operations
    func createSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        let context = container.viewContext
        let splitExpenseEntity = SplitExpenseEntity(context: context)
        splitExpenseEntity.id = splitExpense.id
        splitExpenseEntity.expenseDescription = splitExpense.expenseDescription
        splitExpenseEntity.totalAmount = splitExpense.totalAmount
        splitExpenseEntity.payerID = splitExpense.payerID
        splitExpenseEntity.creationDate = splitExpense.creationDate
        
        try context.save()
        return splitExpense
    }
    
    func getSplitExpense(id: UUID) async throws -> SplitExpense? {
        let context = container.viewContext
        let request = NSFetchRequest<SplitExpenseEntity>(entityName: "SplitExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let splitExpenseEntity = result.first else { return nil }
        
        return SplitExpense(
            id: splitExpenseEntity.id ?? UUID(),
            expenseDescription: splitExpenseEntity.expenseDescription,
            totalAmount: splitExpenseEntity.totalAmount,
            payerID: splitExpenseEntity.payerID ?? UUID(),
            creationDate: splitExpenseEntity.creationDate ?? Date()
        )
    }
    
    func getSplitExpenses(forUserID: UUID) async throws -> [SplitExpense] {
        let context = container.viewContext
        let request = NSFetchRequest<SplitExpenseEntity>(entityName: "SplitExpenseEntity")
        request.predicate = NSPredicate(format: "payerID == %@", forUserID as CVarArg)
        
        let result = try context.fetch(request)
        return try result.compactMap { entity in
            guard let id = entity.id,
                  let payerID = entity.payerID,
                  let creationDate = entity.creationDate else {
                      throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Split Expense not found"])
                  }
            
            return SplitExpense(
                id: id,
                expenseDescription: entity.expenseDescription,
                totalAmount: entity.totalAmount,
                payerID: payerID,
                creationDate: creationDate
            )
        }
    }
    
    func updateSplitExpense(_ splitExpense: SplitExpense) async throws -> SplitExpense {
        let context = container.viewContext
        let request = NSFetchRequest<SplitExpenseEntity>(entityName: "SplitExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", splitExpense.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let splitExpenseEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Split Expense not found"])
        }
        
        splitExpenseEntity.expenseDescription = splitExpense.expenseDescription
        splitExpenseEntity.totalAmount = splitExpense.totalAmount
        splitExpenseEntity.payerID = splitExpense.payerID
        splitExpenseEntity.creationDate = splitExpense.creationDate
        
        try context.save()
        return splitExpense
    }
    
    func deleteSplitExpense(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<SplitExpenseEntity>(entityName: "SplitExpenseEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let splitExpenseEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Split Expense not found"])
        }
        
        context.delete(splitExpenseEntity)
        try context.save()
    }
}

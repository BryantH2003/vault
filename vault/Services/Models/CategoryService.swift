import Foundation
import CoreData

/// Service for managing Category entities
class CategoryService: BaseCoreDataService<CategoryEntity, Category> {
    static let shared = CategoryService(container: CoreDataService.shared.container, entityName: "CategoryEntity")
    
    override func mapModelToEntity(_ model: Category, _ entity: CategoryEntity) async throws {
        entity.id = model.id
        entity.categoryName = model.categoryName
        entity.fixedExpense = model.fixedExpense
    }
    
    override func mapEntityToModel(_ entity: CategoryEntity) async throws -> Category {
        guard let id = entity.id,
              let categoryName = entity.categoryName else {
            throw NSError(domain: "CategoryService", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid entity data"])
        }
        
        return Category(
            id: id,
            categoryName: categoryName,
            fixedExpense: entity.fixedExpense
        )
    }
    
    /// Get a category by name
    func getByName(_ name: String) async throws -> Category? {
        let context = container.viewContext
        let request = NSFetchRequest<CategoryEntity>(entityName: entityName)
        request.predicate = NSPredicate(format: "categoryName == %@", name as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first else { return nil }
        
        return try await mapEntityToModel(entity)
    }
    
    /// Get all fixed expense categories
    func getFixedExpenseCategories() async throws -> [Category] {
        let predicate = NSPredicate(format: "fixedExpense == YES")
        return try await getAllWithPredicate(predicate)
    }
    
    // MARK: - Category Operations
    func createCategory(_ category: Category) async throws -> Category {
        let context = container.viewContext
        let categoryEntity = CategoryEntity(context: context)
        categoryEntity.id = category.id
        categoryEntity.categoryName = category.categoryName
        categoryEntity.fixedExpense = category.fixedExpense
        
        try context.save()
        return category
    }
    
    func getCategory(id: UUID) async throws -> Category? {
        let context = container.viewContext
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let categoryEntity = result.first else { return nil }
        
        return try await mapEntityToModel(categoryEntity)
    }
    
    func getCategories() async throws -> [Category] {
        let context = container.viewContext
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        
        let result = try context.fetch(request)
        var categories: [Category] = []
        for entity in result {
            if let category = try? await mapEntityToModel(entity) {
                categories.append(category)
            }
        }
        return categories
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        let context = container.viewContext
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        request.predicate = NSPredicate(format: "id == %@", category.id as CVarArg)
        
        let result = try context.fetch(request)
        guard let categoryEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
        }
        
        categoryEntity.categoryName = category.categoryName
        categoryEntity.fixedExpense = category.fixedExpense
        
        try context.save()
        return category
    }
    
    func deleteCategory(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<CategoryEntity>(entityName: "CategoryEntity")
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let categoryEntity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Category not found"])
        }
        
        context.delete(categoryEntity)
        try context.save()
    }
}

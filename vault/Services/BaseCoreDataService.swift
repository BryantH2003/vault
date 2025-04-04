import Foundation
import CoreData

class BaseCoreDataService<T: NSManagedObject, M> {
    let container: NSPersistentContainer
    let entityName: String
    
    init(container: NSPersistentContainer, entityName: String) {
        self.container = container
        self.entityName = entityName
    }
    
    func mapModelToEntity(_ model: M, _ entity: T) async throws {
        fatalError("Must override mapModelToEntity")
    }
    
    func mapEntityToModel(_ entity: T) async throws -> M {
        fatalError("Must override mapEntityToModel")
    }
    
    func create(_ model: M) async throws -> M {
        let context = container.viewContext
        let entity = T(context: context)
        
        try await mapModelToEntity(model, entity)
        try context.save()
        
        return model
    }
    
    func get(id: UUID) async throws -> M? {
        let context = container.viewContext
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first else { return nil }
        
        return try await mapEntityToModel(entity)
    }
    
    func getAll() async throws -> [M] {
        let context = container.viewContext
        let request = NSFetchRequest<T>(entityName: entityName)
        
        let entities = try context.fetch(request)
        var models: [M] = []
        
        for entity in entities {
            if let model = try? await mapEntityToModel(entity) {
                models.append(model)
            }
        }
        
        return models
    }
    
    func update(_ model: M, id: UUID) async throws -> M {
        let context = container.viewContext
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Entity not found"])
        }
        
        try await mapModelToEntity(model, entity)
        try context.save()
        
        return model
    }
    
    func delete(id: UUID) async throws {
        let context = container.viewContext
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        
        let result = try context.fetch(request)
        guard let entity = result.first else {
            throw NSError(domain: "CoreDataService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Entity not found"])
        }
        
        context.delete(entity)
        try context.save()
    }
    
    func getAllWithPredicate(_ predicate: NSPredicate) async throws -> [M] {
        let context = container.viewContext
        let request = NSFetchRequest<T>(entityName: entityName)
        request.predicate = predicate
        
        let entities = try context.fetch(request)
        var models: [M] = []
        
        for entity in entities {
            if let model = try? await mapEntityToModel(entity) {
                models.append(model)
            }
        }
        
        return models
    }
} 
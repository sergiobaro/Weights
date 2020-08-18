import Foundation
import CoreData
import Combine

struct Weight {

  let weightId: UUID
  let weight: Decimal
  let createdAt: Date
}

protocol WeightRepository {

  func weights() -> AnyPublisher<[Weight], Never>
  func add(weight: Weight) throws
  func remove(weightId: UUID) throws
}

class WeightRepositoryCoreData: WeightRepository {

  static let shared = WeightRepositoryCoreData()

  private let persistantContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "Weigths")
    container.loadPersistentStores { _, error in
      if let error = error {
        print(error)
      }
    }
    return container
  }()
  private let subject = CurrentValueSubject<[Weight], Never>([])

  private init() {
    do {
      try self.send()
    } catch {
      print(error)
    }
  }

  func weights() -> AnyPublisher<[Weight], Never> {
    return self.subject.eraseToAnyPublisher()
  }

  func add(weight: Weight) throws {
    let weightObject = WeightObject(context: self.persistantContainer.viewContext)
    weightObject.weightId = weight.weightId
    weightObject.weight = weight.weight as NSDecimalNumber
    weightObject.createdAt = weight.createdAt

    try self.save()
    try self.send()
  }

  func remove(weightId: UUID) throws {
    guard let weightObject = try self.fetch(weightId: weightId) else {
      return
    }

    self.persistantContainer.viewContext.delete(weightObject)
    try self.save()
    try self.send()
  }

  private func send() throws {
    let weights = try self.fetchAll().map(self.map(weightObject:))
    self.subject.send(weights)
  }

  private func map(weightObject: WeightObject) -> Weight {
    Weight(weightId: weightObject.weightId!,
           weight: weightObject.weight! as Decimal,
           createdAt: weightObject.createdAt!)
  }

  private func fetchAll() throws -> [WeightObject] {
    let request = self.fetchRequest()
    request.sortDescriptors = [NSSortDescriptor(keyPath: \WeightObject.createdAt, ascending: false)]
    return try self.persistantContainer.viewContext.fetch(request)
  }

  private func fetch(weightId: UUID) throws -> WeightObject? {
    let request = self.fetchRequest()
    request.predicate = NSPredicate(format: "weightId == %@", weightId as CVarArg)
    return try self.persistantContainer.viewContext.fetch(request).first
  }

  private func fetchRequest() -> NSFetchRequest<WeightObject> {
    WeightObject.fetchRequest()
  }

  private func save() throws {
    try self.persistantContainer.viewContext.save()
  }
}

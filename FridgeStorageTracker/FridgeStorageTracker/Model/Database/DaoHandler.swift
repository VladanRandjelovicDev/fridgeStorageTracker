import CoreData
import Combine

protocol DaoHandler {

    associatedtype T: NSManagedObject

    var entities: AnyPublisher<[T], Never> { get }

    func insertAll(count: Int, populate: @escaping ([T]) -> Void) throws
    func insert(populate: @escaping (T) -> Void) throws
    func update(id: UUID, populate: @escaping (T) -> Void) throws
    func delete(id: UUID) throws
    func get(id: UUID) throws -> T?
}

import Combine
import Foundation

protocol FoodItemRepository {

    var items: AnyPublisher<[FoodItem], Never> { get }

    func getItem(id: UUID) async throws -> FoodItem?
    func deleteItem(id: UUID) async throws
    func add(
        name: String,
        category: FoodItemCategory,
        bestBeforeDate: Date,
        timeStored: Date
    ) async throws -> FoodItem

    func update(
        id: UUID,
        name: String?,
        category: FoodItemCategory?,
        bestBeforeDate: Date?,
        timeStored: Date?
    ) async throws -> FoodItem
}

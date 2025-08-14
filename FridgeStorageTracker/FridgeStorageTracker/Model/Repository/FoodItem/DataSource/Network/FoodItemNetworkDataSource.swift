import Foundation

protocol FoodItemNetworkDataSource {

    func getAll() async throws -> [FoodItem]
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

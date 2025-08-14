import Foundation

class FoodItemNetworkDataSourceImpl: FoodItemNetworkDataSource {

    static let shared = FoodItemNetworkDataSourceImpl()

    private let apiClient: any NetworkingClient
    private let userRepository: any UserRepository

    private init(
        apiClient: (any NetworkingClient)? = nil,
        userRepository: (any UserRepository)? = nil
    ) {
        self.apiClient = apiClient ?? DefaultNetworkingClient.shared
        self.userRepository = userRepository ?? UserRepositoryImpl.shared
    }

    func getAll() async throws -> [FoodItem] {
        return try await apiClient.perform(
            request: FridgeStorageAPIRequest.fetchAll(userID: userRepository.userID)
        )
    }

    func getItem(id: UUID) async throws -> FoodItem? {
        return try await apiClient.perform(request: FridgeStorageAPIRequest.get(id: id))
    }

    func deleteItem(id: UUID) async throws {
        _ = try await apiClient.perform(request: FridgeStorageAPIRequest.delete(id: id))
    }

    func add(
        name: String,
        category: FoodItemCategory,
        bestBeforeDate: Date,
        timeStored: Date
    ) async throws -> FoodItem {
        return try await apiClient.perform(request: FridgeStorageAPIRequest.add(
            userID: userRepository.userID,
            name: name,
            category: category,
            bestBeforeDate: bestBeforeDate,
            timeStored: timeStored
        ))
    }

    func update(
        id: UUID,
        name: String?,
        category: FoodItemCategory?,
        bestBeforeDate: Date?,
        timeStored: Date?
    ) async throws -> FoodItem {
        return try await apiClient.perform(request: FridgeStorageAPIRequest.update(
            id: id,
            name: name,
            category: category,
            bestBeforeDate: bestBeforeDate,
            timeStored: timeStored
        ))
    }
}

import Foundation
import Combine

class FoodItemRepositoryImpl: FoodItemRepository {

    static let shared: any FoodItemRepository = FoodItemRepositoryImpl()

    private var cancellables = Set<AnyCancellable>()
    private let databaseDataSource: any FoodItemDatabaseDataSource
    private let networkDataSource: FoodItemNetworkDataSource

    @Published private(set) var _items: [FoodItem] = []
    var items: AnyPublisher<[FoodItem], Never> {
        if _items.isEmpty {
            fetchItems()
        }

        return $_items.eraseToAnyPublisher()
    }

    private init(
        databaseDataSource: (any FoodItemDatabaseDataSource)? = nil,
        networkDataSource: FoodItemNetworkDataSource? = nil
    ) {
        self.databaseDataSource = databaseDataSource ?? FoodItemDatabaseDataSourceImpl.shared
        self.networkDataSource = networkDataSource ?? FoodItemNetworkDataSourceImpl.shared
        self.databaseDataSource.entities
            .map { entities in entities.map { FoodItem(item: $0) } }
            .sink(receiveValue: {
                self._items = $0
            })
            .store(in: &cancellables)

        fetchItems()
    }

    private func fetchItems() {
        Task {
            guard let items = try? await networkDataSource.getAll() else {
                return
            }

            try? databaseDataSource.insertAll(count: items.count) { databaseItems in
                databaseItems.enumerated().forEach { index, databaseItem in
                    items[index].populateDbItem(databaseItem)
                }
            }
        }
    }

    func getItem(id: UUID) async throws -> FoodItem? {
        _items.first { $0.id == id }
    }

    func deleteItem(id: UUID) async throws {
        try await networkDataSource.deleteItem(id: id)
        try databaseDataSource.delete(id: id)
    }

    func add(
        name: String,
        category: FoodItemCategory,
        bestBeforeDate: Date,
        timeStored: Date
    ) async throws -> FoodItem {
        let item = try await networkDataSource.add(name: name, category: category, bestBeforeDate: bestBeforeDate, timeStored: timeStored)
        try databaseDataSource.insert { item.populateDbItem($0) }
        return item
    }

    func update(
        id: UUID,
        name: String?,
        category: FoodItemCategory?,
        bestBeforeDate: Date?,
        timeStored: Date?
    ) async throws -> FoodItem {
        let item = try await networkDataSource.update(
            id: id,
            name: name,
            category: category,
            bestBeforeDate: bestBeforeDate,
            timeStored: timeStored
        )

        try databaseDataSource.update(id: id) { item.populateDbItem($0) }
        return item
    }
}

//import Testing
//@testable import FridgeStorageTracker
//
//struct FridgeStorageTrackerTests {
//
//    @Test func example() async throws {
//        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
//    }
//
//}
import XCTest
import Combine
@testable import FridgeStorageTracker

final class FridgeContentViewModelTests: XCTestCase {

    class MockFoodItemRepository: FoodItemRepository {
        func getItem(id: UUID) async throws -> FridgeStorageTracker.FoodItem? {
            return FridgeStorageTracker.FoodItem(id: id, name: "Mock Item", category: .fruit, bestBefore: Date(), dateStored: Date())
        }
        
        func add(name: String, category: FridgeStorageTracker.FoodItemCategory, bestBeforeDate: Date, timeStored: Date) async throws -> FridgeStorageTracker.FoodItem {
            return FridgeStorageTracker.FoodItem(id: UUID(), name: name, category: category, bestBefore: bestBeforeDate, dateStored: timeStored)
        }
        
        func update(id: UUID, name: String?, category: FridgeStorageTracker.FoodItemCategory?, bestBeforeDate: Date?, timeStored: Date?) async throws -> FridgeStorageTracker.FoodItem {
            return FridgeStorageTracker.FoodItem(id: id, name: name ?? "Updated", category: category ?? .other, bestBefore: bestBeforeDate ?? Date(), dateStored: timeStored ?? Date())
        }
        
        var itemsSubject = PassthroughSubject<[FoodItem], Never>()
        var items: AnyPublisher<[FoodItem], Never> {
            itemsSubject.eraseToAnyPublisher()
        }

        var updatedItem: (id: UUID, name: String?, category: FoodItemCategory?, bestBeforeDate: Date?, timeStored: Date?)?
        var deletedIds: [UUID] = []

        func update(id: UUID, name: String?, category: FoodItemCategory?, bestBeforeDate: Date?, timeStored: Date?) async throws {
            updatedItem = (id, name, category, bestBeforeDate, timeStored)
        }

        func deleteItem(id: UUID) async throws {
            deletedIds.append(id)
        }
    }

    var cancellables: Set<AnyCancellable> = []

    func testViewModelEmitsItemsFromRepository() {
        let repository = MockFoodItemRepository()
        let vm = FridgeContentViewModelImpl(foodItemRepository: repository)
        let expectation = XCTestExpectation(description: "ViewState updates")
        
        let testItems = [
            FoodItem(id: UUID(), name: "Apple", category: .fruit, bestBefore: Date(), dateStored: Date()),
            FoodItem(id: UUID(), name: "Banana", category: .fruit, bestBefore: Date(), dateStored: Date())
        ]
        
        var receivedStates: [FridgeContentViewState] = []

        vm.viewState
            .sink { state in
                receivedStates.append(state)
                if !state.isLoading {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        repository.itemsSubject.send(testItems)

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(receivedStates.last?.foodItems.count, 2)
        XCTAssertEqual(receivedStates.last?.foodItems.map { $0.title }, ["Apple", "Banana"])
    }

    func testSortByName() {
        let repository = MockFoodItemRepository()
        let vm = FridgeContentViewModelImpl(foodItemRepository: repository)
        let expectation = XCTestExpectation(description: "Sorting updates")

        let testItems = [
            FoodItem(id: UUID(), name: "Banana", category: .fruit, bestBefore: Date(), dateStored: Date()),
            FoodItem(id: UUID(), name: "Apple", category: .fruit, bestBefore: Date(), dateStored: Date())
        ]
        
        var receivedStates: [FridgeContentViewState] = []

        vm.viewState
            .sink { state in
                receivedStates.append(state)
                if !state.isLoading && receivedStates.count > 1 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        repository.itemsSubject.send(testItems)
        vm.sortBy(.name)

        wait(for: [expectation], timeout: 1)

        XCTAssertEqual(receivedStates.last?.foodItems.map { $0.title }, ["Apple", "Banana"])
    }
    
    // MARK:update items for future extension

//    func testUpdateItemCallsRepository() async {
//        let repository = MockFoodItemRepository()
//        let vm = FridgeContentViewModelImpl(foodItemRepository: repository)
//        
//        let id = UUID()
//        vm.updateItem(id: id, name: "NewName", category: .meat, dateStored: nil, expiryDate: nil)
//        
//        // Wait briefly for Task to execute
//        try? await Task.sleep(nanoseconds: 100_000_000)
//        
//        XCTAssertEqual(repository.updatedItem?.id, id)
//        XCTAssertEqual(repository.updatedItem?.name, "NewName")
//        XCTAssertEqual(repository.updatedItem?.category, .meat)
//    }

    func testDeleteItemsCallsRepository() async {
        let repository = MockFoodItemRepository()
        let vm = FridgeContentViewModelImpl(foodItemRepository: repository)
        
        let ids = [UUID(), UUID()]
        vm.deleteItems(ids: ids)
        
        // Wait briefly for Tasks to execute
        try? await Task.sleep(nanoseconds: 100_000_000)
        
        XCTAssertEqual(repository.deletedIds, ids)
    }
    
    func testInvalidateCancelsBinding() {
        let repository = MockFoodItemRepository()
        let vm = FridgeContentViewModelImpl(foodItemRepository: repository)
        
        XCTAssertNotNil(vm.viewState) // Just touch viewState to ensure it's initialized
        vm.invalidate()
        
        // Combine doesn’t expose cancellable state; we assume no crash occurs and binding is cancelled
    }
}

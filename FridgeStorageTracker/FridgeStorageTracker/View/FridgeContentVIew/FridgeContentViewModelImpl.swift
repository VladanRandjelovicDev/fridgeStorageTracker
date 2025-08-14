import Combine
import Foundation

class FridgeContentViewModelImpl : FridgeContentViewModel {

    @Published private var _viewState: FridgeContentViewState = .loading()
    private var sortedBy = FridgeContentViewState.SortByType.name
    private var bindingCancelable: AnyCancellable?
    private var cachedItems: [FoodItem]?

    private let foodItemRepository: any FoodItemRepository

    var viewState: AnyPublisher<FridgeContentViewState, Never> {
        $_viewState.eraseToAnyPublisher()
    }

    init(foodItemRepository: (any FoodItemRepository)? = nil) {
        self.foodItemRepository = foodItemRepository ?? FoodItemRepositoryImpl.shared
        observeFoodItems()
    }

    private func observeFoodItems() {
        bindingCancelable = foodItemRepository
            .items
            .sink(receiveValue: { [weak self] in
                self?.cachedItems = $0
                self?.emitNewItems($0)
            })
    }

    private func emitNewItems(_ foodItems: [FoodItem]) {
        let sortedFoodItems = foodItems.sorted(by: { (lhs, rhs) in
            switch self.sortedBy {
            case .name:
                return lhs.name < rhs.name
            case .expiryDate:
                return lhs.bestBefore < rhs.bestBefore
            case .dateStored:
                return lhs.dateStored < rhs.dateStored
            }
        })

        let foodItemsViewStates = sortedFoodItems.map {
            FridgeContentViewState.FoodItemViewState(foodItem: $0)
        }
        
        _viewState = FridgeContentViewState(
            isLoading: false,
            sortedBy: sortedBy,
            foodItems: foodItemsViewStates
        )
    }

    func updateItem(id: UUID, name: String?, category: FoodItemCategory?, dateStored: Date?, expiryDate: Date?) {
        Task {
            try? await foodItemRepository.update(
                id: id,
                name: name,
                category: category,
                bestBeforeDate: dateStored,
                timeStored: expiryDate
            )
        }
    }

    func deleteItems(ids: [UUID]) {
        ids.forEach { id in
            Task {
                try? await foodItemRepository.deleteItem(id: id)
            }
        }
    }

    func sortBy(_ sortFilter: FridgeContentViewState.SortByType) {
        sortedBy = sortFilter
        emitNewItems(cachedItems ?? [])
    }

    func invalidate() {
        bindingCancelable?.cancel()
    }
}

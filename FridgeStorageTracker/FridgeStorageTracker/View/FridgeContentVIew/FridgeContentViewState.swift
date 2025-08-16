import Foundation

struct FridgeContentViewState: Equatable {

    let isLoading: Bool
    let sortedBy: FridgeContentViewState.SortByType
    let foodItems: [FridgeContentViewState.FoodItemViewState]

    static func loading() -> FridgeContentViewState {
        FridgeContentViewState(isLoading: true, sortedBy: .name, foodItems: [])
    }
}

extension FridgeContentViewState {

    struct FoodItemViewState: Equatable, Hashable {
        let id: UUID
        let title: String
        let category: FoodItemCategory
        let storedDate: String
        let expiresInDays: Int?

        init(foodItem: FoodItem) {
            id = foodItem.id
            title = foodItem.name
            category = foodItem.category
            storedDate = foodItem.dateStored.formatted()
            expiresInDays = Int(foodItem.bestBefore.distance(to: foodItem.dateStored) / 86400)
        }
    }

    enum SortByType: Equatable {
        case name
        case dateStored
        case expiryDate
    }
}

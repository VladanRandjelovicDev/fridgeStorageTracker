import Combine
import Foundation

class AddFoodItemViewModelImpl: AddFoodItemViewModel {

    private let foodItemRepository: any FoodItemRepository

    init(foodItemRepository: (any FoodItemRepository)? = nil) {
        self.foodItemRepository = foodItemRepository ?? FoodItemRepositoryImpl.shared
    }

    func addItem(name: String, category: FoodItemCategory, dateStored: Date, expiryDate: Date) async {
        try? await foodItemRepository.add(
            name: name,
            category: category,
            bestBeforeDate: dateStored,
            timeStored: expiryDate
        )
    }
}

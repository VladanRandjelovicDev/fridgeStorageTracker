import Foundation
import Combine

protocol AddFoodItemViewModel {

    func addItem(name: String, category: FoodItemCategory, dateStored: Date, expiryDate: Date) async
}

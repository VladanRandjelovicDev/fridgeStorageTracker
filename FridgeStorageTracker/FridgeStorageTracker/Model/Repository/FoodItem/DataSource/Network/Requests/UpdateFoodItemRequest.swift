import Foundation

struct UpdateFoodItemRequest: Encodable {

    let name: String?
    let category: FoodItemCategory?
    let bestBefore: Date?
    let dateStored: Date?
}

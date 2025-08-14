import Foundation

struct CreateFoodItemRequest: Encodable {

    let userId: String
    let name: String
    let category: FoodItemCategory
    let bestBefore: Date
    let dateStored: Date
}

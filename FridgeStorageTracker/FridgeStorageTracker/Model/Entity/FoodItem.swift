import Foundation

struct FoodItem: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let category: FoodItemCategory
    let bestBefore: Date
    let dateStored: Date

    init(item: FoodItemDatatabaseEntity) {
        id = item.id!
        name = item.name!
        category = FoodItemCategory(rawValue: item.category!) ?? .other
        bestBefore = item.bestBefore!
        dateStored = item.dateStored!
    }

    func populateDbItem(_ item: FoodItemDatatabaseEntity) {
        item.id = id
        item.name = name
        item.category = category.rawValue
        item.bestBefore = bestBefore
        item.dateStored = dateStored
    }
}

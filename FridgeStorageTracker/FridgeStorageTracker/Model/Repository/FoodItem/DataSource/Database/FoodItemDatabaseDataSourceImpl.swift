import Foundation

class FoodItemDatabaseDataSourceImpl: DaoHandlerImpl<FoodItemDatatabaseEntity>, FoodItemDatabaseDataSource {

    static let shared = FoodItemDatabaseDataSourceImpl()

    private init() { }
}

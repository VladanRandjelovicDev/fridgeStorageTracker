import Foundation
import Combine

protocol FridgeContentViewModel {

    var viewState: AnyPublisher<FridgeContentViewState, Never> { get }

    func updateItem(id: UUID, name: String?, category: FoodItemCategory?, dateStored: Date?, expiryDate: Date?)
    func deleteItems(ids: [UUID])
    func sortBy(_ sortFilter: FridgeContentViewState.SortByType)
    func invalidate()
}

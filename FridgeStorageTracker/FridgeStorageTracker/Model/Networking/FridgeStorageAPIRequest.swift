import Foundation

private struct Constants {
    static let baseUrl = URL(string: "http://127.0.0.1:3785")!
}

enum FridgeStorageAPIRequest: APIRequest {

    case add(
        userID: String,
        name: String,
        category: FoodItemCategory,
        bestBeforeDate: Date,
        timeStored: Date
    )

    case update(
        id: UUID,
        name: String?,
        category: FoodItemCategory?,
        bestBeforeDate: Date?,
        timeStored: Date?
    )
    case fetchAll(userID: String)
    case get(id: UUID)
    case delete(id: UUID)
}

// MARK: - Base URL

extension FridgeStorageAPIRequest {

    var baseURL: URL {
        return Constants.baseUrl
    }
}


// MARK: - Method

extension FridgeStorageAPIRequest {

    var method: Method {

        switch self {
        case .add:
            return .post
        case .update:
            return .put
        case .fetchAll, .get:
            return .get
        case .delete:
            return .delete
        }
    }
}

// MARK: - Path

extension FridgeStorageAPIRequest {

    var path: String {

        switch self {
        case .add:
            return "/items"
        case .update(let id, _, _, _, _):
            return "/items/\(id)"
        case .fetchAll(let userID):
            return "/items/\(userID)"
        case .get(let id):
            return "/items/\(id.uuidString)"
        case .delete(let id):
            return "/items/\(id.uuidString)"
        }
    }
}

// MARK: - Body

extension FridgeStorageAPIRequest {

    var body: (any Encodable)? {
        switch self {
        case .add(
            let userID,
            let name,
            let category,
            let bestBeforeDate,
            let timeStored
        ): return CreateFoodItemRequest(
            userId: userID,
            name: name,
            category: category,
            bestBefore: bestBeforeDate,
            dateStored: timeStored
        )

        case .update(
            _,
            let name,
            let category,
            let bestBeforeDate,
            let timeStored
        ): return UpdateFoodItemRequest(
            name: name,
            category: category,
            bestBefore: bestBeforeDate,
            dateStored: timeStored
        )

        default:
            return nil
        }
    }
}

// MARK: - Headers

extension FridgeStorageAPIRequest {

    var headers: [String: String]? {
        //TODO: We should return JWT tokens or other auth related and security related headers
        //but since we don't have the real API that implementation will be skipped
        return nil
    }
}

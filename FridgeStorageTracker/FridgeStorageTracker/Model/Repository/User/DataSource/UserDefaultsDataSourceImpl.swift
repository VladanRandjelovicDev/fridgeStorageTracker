import Foundation

private struct Constants {

    static let userIDKey = "userID"
}

class UserDefaultsDataSourceImpl: UserDefaultsDataSource {

    static let shared: UserDefaultsDataSource = UserDefaultsDataSourceImpl()

    let userID: String

    private init(
        userDefaults: UserDefaults? = nil
    ) {
        let defaults = userDefaults ?? UserDefaults.standard
        let id = defaults.string(forKey: Constants.userIDKey)
        if let id {
            userID = id
        } else {
            userID = UUID().uuidString
            defaults.set(userID, forKey: Constants.userIDKey)
        }
    }
}

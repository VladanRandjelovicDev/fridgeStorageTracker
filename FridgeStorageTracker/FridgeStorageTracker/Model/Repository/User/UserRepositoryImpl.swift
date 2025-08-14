class UserRepositoryImpl: UserRepository {

    static let shared: any UserRepository = UserRepositoryImpl()

    private let userDefaultsDataSource: any UserDefaultsDataSource

    var userID: String {
        userDefaultsDataSource.userID
    }

    private init(
        userDefaultsDataSource: (any UserDefaultsDataSource)? = nil
    ) {
        self.userDefaultsDataSource = userDefaultsDataSource ?? UserDefaultsDataSourceImpl.shared
    }
}

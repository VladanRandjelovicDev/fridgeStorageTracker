import Foundation

protocol NetworkingClient {

    /// Performs API request and returns generic response that can be used for any result type
    func perform(request: APIRequest) async throws -> Data

    /// Performs API request and returns generic response that is obtained by parsing JSON response
    func perform<T: Decodable>(request: APIRequest) async throws -> T

}

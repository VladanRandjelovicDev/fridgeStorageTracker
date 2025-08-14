import Foundation

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case decodingFailed
    case httpError(statusCode: Int, data: Data)
}

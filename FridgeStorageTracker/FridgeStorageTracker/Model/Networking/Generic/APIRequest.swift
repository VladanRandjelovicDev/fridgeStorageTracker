import Foundation

protocol APIRequest {

    var baseURL: URL { get }
    var method: Method { get }
    var body: (any Encodable)? { get }
    var path: String { get }
    var headers: [String: String]? { get }
}

enum Method: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

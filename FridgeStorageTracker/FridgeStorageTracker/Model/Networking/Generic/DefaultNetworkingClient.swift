import Foundation

final class DefaultNetworkingClient: NetworkingClient {

    static let shared = DefaultNetworkingClient()
    
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    func perform(request: APIRequest) async throws -> Data {
        guard let url = URL(string: request.path, relativeTo: request.baseURL) else {
            throw NetworkError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue

        request.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        if let body = request.body {
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return data
    }

    func perform<T: Decodable>(request: APIRequest) async throws -> T {
        do {
            let data = try await perform(request: request)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }
}

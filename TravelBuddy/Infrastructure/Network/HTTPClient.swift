//
//  HTTPClient.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//

// Infrastructure/Networking/HTTPClient.swift
import Foundation
import Combine

public final class HTTPClient: HTTPClientProtocol {
    private let timeout: TimeInterval
    private let decoder: JSONDecoder

    public init(timeout: TimeInterval = 15,
                decoder: JSONDecoder = .init()) {
        self.timeout = timeout
        self.decoder = decoder
    }

    public func send<T: Decodable>(_ requestIn: URLRequest) -> AnyPublisher<T, Error> {
        var request = requestIn
        // если у запроса не задан таймаут – подставим дефолт из клиента
        if request.timeoutInterval == 0 {
            request.timeoutInterval = timeout
        }

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { output -> Data in
                // маппим network-ошибки и статусы
                if let http = output.response as? HTTPURLResponse,
                   !(200...299).contains(http.statusCode) {
                    throw URLError(.badServerResponse)
                }
                return output.data
            }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }
}

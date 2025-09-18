//
//  HTTPClient.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//

import Foundation
import Combine

public final class HTTPClient: HTTPClientProtocol {
    public init() {}
    public func send<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
        var request = request
        request.timeoutInterval = 0.1 // секунд
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

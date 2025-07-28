//
//  HTTPClient 2.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 7/28/25.
//

import Foundation
import Combine

public final class HTTPClient: HTTPClientProtocol {
  public init() {}
  public func send<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error> {
    URLSession.shared.dataTaskPublisher(for: request)
      .map(\.data)
      .decode(type: T.self, decoder: JSONDecoder())
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

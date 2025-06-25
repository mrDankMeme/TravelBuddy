//
//  HTTPClient.swift
//  TravelBuddy
//
//  Created by Niiaz Khasanov on 6/20/25.
//


import Foundation
import Combine

public protocol HTTPClientProtocol {
  func send<T: Decodable>(_ request: URLRequest) -> AnyPublisher<T, Error>
}

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

